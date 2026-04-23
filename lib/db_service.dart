import 'database_helper.dart';
import 'app_state.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class DbService {
  static Future<void> salvarLeitura({
    required String codigo,
    required String loja,
    required String secao,
    required String coletor,
    int lido = 1,
    int quantidade = 1,
  }) async {
    try {
      final db = await DatabaseHelper.getDatabase();

      final uuid = Uuid().v4();
      final agora = DateTime.now().toIso8601String();
      final lojaNormalizada = loja.trim();
      final secaoNormalizada = secao.trim();
      final coletorNormalizado = coletor.trim();

      // Get columns to determine schema
      final columns = await getPcdescColumns();
      final hasDatahora = columns.contains('datahora');
      final hasDia = columns.contains('dia');
      final hasHora = columns.contains('hora');
      final hasQtde = columns.contains('qtde');

      // Build insert statement dynamically
      final insertColumns = ['codigo', 'loja', 'secao', 'coletor', 'lido', 'chave'];
      final values = [codigo, lojaNormalizada, secaoNormalizada, coletorNormalizado, lido, uuid];

      if (hasDatahora) {
        insertColumns.add('datahora');
        values.add(agora);
      } else if (hasDia && hasHora) {
        insertColumns.add('dia');
        insertColumns.add('hora');
        final parts = agora.split('T'); // ISO format: 2023-04-12T14:30:00.000
        
        // Convertendo para o formato desejado
        final dateParts = parts[0].split('-'); // [YYYY, MM, DD]
        final timeParts = parts[1].split(':'); // [HH, mm, ss.mmm]
        
        // Dia em formato DDMMYY (ex: 070101)
        final dia = '${dateParts[2]}${dateParts[1]}${dateParts[0].substring(2)}';
        
        // Hora em formato HHMMSS (ex: 205303)
        final hora = '${timeParts[0]}${timeParts[1]}${timeParts[2].split('.')[0]}';
        
        values.add(dia);
        values.add(hora);
      } else {
        throw Exception('Tabela pcdesc não possui colunas de data/hora compatíveis');
      }

      if (hasQtde) {
        insertColumns.add('qtde');
        values.add(quantidade);
      } else {
        throw Exception('Tabela pcdesc não possui a coluna qtde');
      }

      final placeholders = List.filled(values.length, '?').join(', ');
      final sql = 'INSERT INTO pcdesc (${insertColumns.join(', ')}) VALUES ($placeholders)';

      final result = await db.rawInsert(sql, values);

      if (result == 0) {
        throw Exception('Falha ao inserir registro no banco de dados');
      }
    } catch (e) {
      throw Exception('Erro ao salvar leitura: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> getItensPorLoja({
    String pesquisa = '',
  }) async {
    final db = await DatabaseHelper.getDatabase();
    final busca = pesquisa.trim().toLowerCase();
    final params = [AppState.loja, AppState.nome];
    final filtroBusca = busca.isNotEmpty
        ? ' AND (lower(trim(d.codigo)) LIKE ? OR lower(trim(ifnull(p.descr, \'\'))) LIKE ?)'
        : '';

    if (busca.isNotEmpty) {
      final termo = '%$busca%';
      params.addAll([termo, termo]);
    }

    return await db.rawQuery('''
      SELECT 
        d.codigo,
        d.secao,
        SUM(d.qtde) as quantidade,
        MIN(d.chave) as chave,
        p.descr
      FROM pcdesc d
      LEFT JOIN pcprod p ON p.codigo = d.codigo
      WHERE trim(d.loja) = trim(?)
        AND trim(d.coletor) = trim(?)
        $filtroBusca
      GROUP BY d.codigo, d.secao, p.descr
      ORDER BY d.secao
    ''', params);
  }

  static Future<List<Map<String, dynamic>>> getItensPorSecao() async {
    final db = await DatabaseHelper.getDatabase();
    final columns = await getPcdescColumns();
    final hasDatahora = columns.contains('datahora');

    String selectDatahora;
    String orderByDatahora;

    if (hasDatahora) {
      selectDatahora = 'd.datahora';
      orderByDatahora = 'd.datahora DESC';
    } else {
      selectDatahora = 'd.dia || \' \' || d.hora';
      orderByDatahora = 'd.dia DESC, d.hora DESC';
    }

    return await db.rawQuery(
      '''
      SELECT 
        d.chave,
        d.codigo,
        d.qtde,
        p.descr,
        $selectDatahora as datahora
      FROM pcdesc d
      LEFT JOIN pcprod p ON p.codigo = d.codigo
      WHERE trim(d.loja) = trim(?)
        AND trim(d.secao) = trim(?)
        AND trim(d.coletor) = trim(?)
      ORDER BY $orderByDatahora
    ''',
      [AppState.loja, AppState.secao, AppState.nome],
    );
  }

  static Future<int> getTotalItens() async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.rawQuery(
      'SELECT SUM(qtde) as total FROM pcdesc WHERE trim(loja) = trim(?) AND trim(secao) = trim(?) AND trim(coletor) = trim(?)',
      [AppState.loja, AppState.secao, AppState.nome],
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> removerUmItem(String codigo) async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query(
      'pcdesc',
      where:
          'trim(codigo) = ? AND trim(loja) = trim(?) AND trim(secao) = trim(?) AND trim(coletor) = trim(?)',
      whereArgs: [codigo, AppState.loja, AppState.secao, AppState.nome],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final chave = result.first['chave'];
      final qtdeAtual = result.first['qtde'] as int? ?? 1;

      if (qtdeAtual > 1) {
        // Reduzir quantidade em 1
        await db.update(
          'pcdesc',
          {'qtde': qtdeAtual - 1},
          where: 'chave = ?',
          whereArgs: [chave],
        );
      } else {
        // Se quantidade é 1 ou menos, remover o registro
        await db.delete('pcdesc', where: 'chave = ?', whereArgs: [chave]);
      }
    }
  }

  static Future<void> removerItemPorChave(String chave) async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query(
      'pcdesc',
      where: 'chave = ?',
      whereArgs: [chave],
      limit: 1,
    );

    if (result.isNotEmpty) {
      final qtdeAtual = result.first['qtde'] as int? ?? 1;

      if (qtdeAtual > 1) {
        // Reduzir quantidade em 1
        await db.update(
          'pcdesc',
          {'qtde': qtdeAtual - 1},
          where: 'chave = ?',
          whereArgs: [chave],
        );
      } else {
        // Se quantidade é 1 ou menos, remover o registro
        await db.delete('pcdesc', where: 'chave = ?', whereArgs: [chave]);
      }
    }
  }

  static Future<String?> getDescricaoProduto(String codigo) async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query(
      'pcprod',
      columns: ['descr'],
      where: 'codigo = ?',
      whereArgs: [codigo],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['descr'] as String?;
    }

    return null;
  }

  static Future<void> exportarBanco() async {
    final db = await DatabaseHelper.getDatabase();

    // caminho do banco no app
    final dbPath = db.path;

    // pasta temporária
    final directory = await getTemporaryDirectory();
    final exportPath = '${directory.path}/DBdados_export.db3';

    // copia o arquivo
    final file = File(dbPath);
    await file.copy(exportPath);

    // compartilhar
    await SharePlus.instance.share(
      ShareParams(files: [XFile(exportPath)], text: 'Banco de dados exportado'),
    );
  }

  static Future<bool> importarBanco() async {
    try {
      // Selecionar arquivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        dialogTitle: 'Selecionar arquivo de banco de dados (.db3)',
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty || result.files.single.path == null) {
        return false; // Usuário cancelou
      }

      final arquivoSelecionado = File(result.files.single.path!);

      // Verificar extensão do arquivo
      if (!arquivoSelecionado.path.toLowerCase().endsWith('.db3')) {
        throw Exception('Por favor, selecione um arquivo com extensão .db3');
      }

      // Verificar se o arquivo existe
      if (!await arquivoSelecionado.exists()) {
        throw Exception('Arquivo selecionado não existe');
      }

      // Verificar tamanho do arquivo (banco vazio tem ~100KB)
      final fileSize = await arquivoSelecionado.length();
      if (fileSize < 1000) { // Menos de 1KB provavelmente não é um banco válido
        throw Exception('Arquivo muito pequeno. Selecione um banco de dados válido.');
      }

      // Verificar se é um banco SQLite válido tentando abri-lo
      Database? testDb;
      try {
        testDb = await openDatabase(arquivoSelecionado.path, readOnly: true);
        
        // Verificar se as tabelas necessárias existem
        final tables = await testDb.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tableNames = tables.map((t) => t['name'] as String).toList();
        
        if (!tableNames.contains('pcdesc')) {
          throw Exception('O banco selecionado não contém a tabela pcdesc necessária');
        }
        if (!tableNames.contains('pcprod')) {
          throw Exception('O banco selecionado não contém a tabela pcprod necessária');
        }
        
        await testDb.close();
      } catch (e) {
        if (testDb != null) {
          await testDb.close();
        }
        throw Exception('Erro ao validar banco: ${e.toString()}');
      }

      // Fechar conexão atual
      final db = await DatabaseHelper.getDatabase();
      await db.close();

      // Caminho do banco atual
      final dbPath = db.path;

      // Fazer backup do banco atual
      final backupPath = '$dbPath.backup';
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.copy(backupPath);
      }

      // Copiar o novo banco
      await arquivoSelecionado.copy(dbPath);

      // Reinicializar a conexão
      await DatabaseHelper.resetConnection();

      return true;
    } catch (e) {
      // Em caso de erro, tentar restaurar backup
      try {
        final db = await DatabaseHelper.getDatabase();
        final dbPath = db.path;
        final backupPath = '$dbPath.backup';

        final backupFile = File(backupPath);
        if (await backupFile.exists()) {
          await backupFile.copy(dbPath);
          await DatabaseHelper.resetConnection();
        }
      } catch (_) {
        // Ignorar erro de restauração
      }

      rethrow;
    }
  }

  static Future<void> ensureSenhaTable() async {
    final db = await DatabaseHelper.getDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS config_senha (
        id INTEGER PRIMARY KEY,
        senha TEXT NOT NULL
      )
    ''');
  }

  static Future<String?> getConfigSenha() async {
    await ensureSenhaTable();
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query(
      'config_senha',
      columns: ['senha'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['senha'] as String?;
    }

    return null;
  }

  static Future<void> salvarConfigSenha(String senha) async {
    await ensureSenhaTable();
    final db = await DatabaseHelper.getDatabase();

    await db.insert(
      'config_senha',
      {'id': 1, 'senha': senha},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> hasConfigSenha() async {
    return await getConfigSenha() != null;
  }

  static Future<void> ensureAreaTable() async {
    final db = await DatabaseHelper.getDatabase();
    await db.execute('''
      CREATE TABLE IF NOT EXISTS config_area (
        id INTEGER PRIMARY KEY,
        area TEXT NOT NULL
      )
    ''');
  }

  static Future<String?> getConfigArea() async {
    await ensureAreaTable();
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query(
      'config_area',
      columns: ['area'],
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['area'] as String?;
    }

    return null;
  }

  static Future<void> salvarConfigArea(String area) async {
    await ensureAreaTable();
    final db = await DatabaseHelper.getDatabase();

    await db.insert(
      'config_area',
      {'id': 1, 'area': area},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<bool> hasConfigArea() async {
    return await getConfigArea() != null;
  }

  static Future<Map<String, dynamic>> verificarEstadoBanco() async {
    try {
      final db = await DatabaseHelper.getDatabase();
      
      // Verificar tabelas existentes
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((t) => t['name'] as String).toList();
      
      // Verificar estrutura da tabela pcdesc
      Map<String, dynamic> pcdescInfo = {};
      if (tableNames.contains('pcdesc')) {
        final columns = await db.rawQuery("PRAGMA table_info(pcdesc)");
        pcdescInfo = {
          'exists': true,
          'columns': columns.length,
          'columnNames': columns.map((c) => c['name']).toList(),
        };
        
        // Contar registros
        final count = await db.rawQuery("SELECT COUNT(*) as total FROM pcdesc");
        pcdescInfo['records'] = count.first['total'];
      } else {
        pcdescInfo = {'exists': false};
      }
      
      // Verificar estrutura da tabela pcprod
      Map<String, dynamic> pcprodInfo = {};
      if (tableNames.contains('pcprod')) {
        final columns = await db.rawQuery("PRAGMA table_info(pcprod)");
        pcprodInfo = {
          'exists': true,
          'columns': columns.length,
          'columnNames': columns.map((c) => c['name']).toList(),
        };
        
        // Contar registros
        final count = await db.rawQuery("SELECT COUNT(*) as total FROM pcprod");
        pcprodInfo['records'] = count.first['total'];
      } else {
        pcprodInfo = {'exists': false};
      }
      
      return {
        'success': true,
        'tables': tableNames,
        'pcdesc': pcdescInfo,
        'pcprod': pcprodInfo,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getLojas() async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query('Lojas');

    return result;
  }

  static Future<List<String>> getPcdescColumns() async {
    final db = await DatabaseHelper.getDatabase();
    final result = await db.rawQuery("PRAGMA table_info(pcdesc)");
    return result.map((row) => row['name'] as String).toList();
  }
}
