import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static Database? _database;
  static const int _databaseVersion = 1;

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "DBdados.db3");

    // Verificar versionamento do banco
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt('db_version') ?? 0;

    // Se a versão mudou, copiar novo banco dos assets
    if (currentVersion != _databaseVersion) {
      // Deletar banco antigo se existir
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      // Copiar novo banco dos assets
      ByteData data = await rootBundle.load("assets/database/DBdados.db3");
      List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);

      // Atualizar versão
      await prefs.setInt('db_version', _databaseVersion);
    }

    _database = await openDatabase(path);
    return _database!;
  }

  static Future<void> resetConnection() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}