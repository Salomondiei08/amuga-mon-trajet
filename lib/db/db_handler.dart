

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHandler {
  DbHandler._();
  static Database _database;
  static final DbHandler db = DbHandler._();
  final String dbFile = "gtfs.sqlite";

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    var databasePath = await getDatabasesPath();
    var dbPath = join(databasePath, dbFile);

    bool exist = await databaseExists(dbPath);

    if (!exist) {
      print("Creating a new copy from asset");

      try {
        await Directory(dirname(dbPath)).create(recursive: true);
      } catch (e) {
        print(e);
      }

      // copy from asset
      ByteData data = await rootBundle.load(join("assets", dbFile));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // write and flush the bytes written
      await File(dbPath).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    return openDatabase(dbPath);
  }

}