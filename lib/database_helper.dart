import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;
  

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "DBdados.db3");

    if (!await File(path).exists()) {
      ByteData data = await rootBundle.load("assets/database/DBdados.db3");
      List<int> bytes = data.buffer.asUint8List();

      await File(path).writeAsBytes(bytes);
    }
    _database = await openDatabase(path);
    return _database!;
  
  }
}