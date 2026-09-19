import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Opens the on-device sqlite database used for basal/glucose logs and
/// saved food labels. Nothing here ever leaves the device — there is no
/// network layer. On web this stores into the browser's IndexedDB (via
/// sqflite_common_ffi_web) rather than a native sqlite file, since plain
/// sqflite has no web implementation at all.
class AppDatabase {
  static const _dbName = 'dose_glucose_log.db';
  static const _dbVersion = 2;

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    final path = kIsWeb ? _dbName : p.join(await getDatabasesPath(), _dbName);
    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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
    await _createFoodLabelsTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createFoodLabelsTable(db);
    }
  }

  Future<void> _createFoodLabelsTable(Database db) async {
    await db.execute('''
      CREATE TABLE food_labels (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        serving_size_text TEXT,
        carbs_per_serving REAL NOT NULL,
        sugars_per_serving REAL,
        image_bytes BLOB NOT NULL,
        created_at INTEGER NOT NULL
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
