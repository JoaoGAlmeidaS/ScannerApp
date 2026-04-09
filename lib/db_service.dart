import 'database_helper.dart';
import 'app_state.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DbService {
  static Future<void> salvarLeitura({
    required String codigo,
    required String loja,
    required String secao,
    required String coletor,
    int lido = 1,
  }) async {
    final db = await DatabaseHelper.getDatabase();

    final uuid = Uuid().v4();
    final agora = DateTime.now().toIso8601String();
    final lojaNormalizada = loja.trim();
    final secaoNormalizada = secao.trim();
    final coletorNormalizado = coletor.trim();

    await db.insert('pcdesc', {
      'codigo': codigo,
      'codigoInterno': null,
      'cor': null,
      'loja': lojaNormalizada,
      'area': null,
      'secao': secaoNormalizada,
      'coletor': coletorNormalizado,
      'datahora': agora,
      'lido': lido,
      'chave': uuid,
    });
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
        COUNT(*) as quantidade,
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

    return await db.rawQuery(
      '''
      SELECT 
        d.chave,
        d.codigo,
        p.descr,
        d.datahora
      FROM pcdesc d
      LEFT JOIN pcprod p ON p.codigo = d.codigo
      WHERE trim(d.loja) = trim(?)
        AND trim(d.secao) = trim(?)
        AND trim(d.coletor) = trim(?)
      ORDER BY d.datahora DESC
    ''',
      [AppState.loja, AppState.secao, AppState.nome],
    );
  }

  static Future<int> getTotalItens() async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as total FROM pcdesc WHERE trim(loja) = trim(?) AND trim(secao) = trim(?) AND trim(coletor) = trim(?)',
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

      await db.delete('pcdesc', where: 'chave = ?', whereArgs: [chave]);
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

  static Future<List<Map<String, dynamic>>> getLojas() async {
    final db = await DatabaseHelper.getDatabase();

    final result = await db.query('Lojas');

    return result;
  }
}
