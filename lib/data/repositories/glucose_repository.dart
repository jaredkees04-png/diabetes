import '../../domain/models/glucose_entry.dart';
import '../database/app_database.dart';

class GlucoseRepository {
  GlucoseRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<GlucoseEntry>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('glucose_entries', orderBy: 'timestamp DESC');
    return rows.map(GlucoseEntry.fromMap).toList();
  }

  Future<void> insert(GlucoseEntry entry) async {
    final db = await _appDatabase.database;
    await db.insert('glucose_entries', entry.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('glucose_entries', where: 'id = ?', whereArgs: [id]);
  }
}
