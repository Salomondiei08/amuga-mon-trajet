import 'package:path/path.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sqflite/sqflite.dart' as sql;

class NoSqlDbHandler {
  NoSqlDbHandler._();
  static final NoSqlDbHandler db = NoSqlDbHandler._();
  final String dbFile = "shapes.db";
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    var databasePath = await sql.getDatabasesPath();
    var dbPath = join(databasePath, dbFile);
    return databaseFactoryIo.openDatabase(dbPath);
  }

  Future<bool> isCreated() async {
    var databasePath = await sql.getDatabasesPath();
    var dbPath = join(databasePath, dbFile);

    return await sql.databaseExists(dbPath);

  }



}