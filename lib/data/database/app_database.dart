import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens the on-device sqlite database used for basal and glucose logs.
/// Nothing here ever leaves the device — there is no network layer.
class AppDatabase {
  static const _dbName = 'dose_glucose_log.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    final db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
    _db = db;
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE basal_entries (
        id TEXT PRIMARY KEY,
        units REAL NOT NULL,
        timestamp INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE glucose_entries (
        id TEXT PRIMARY KEY,
        reading REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        note TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
