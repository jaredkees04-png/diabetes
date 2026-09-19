import '../../domain/models/basal_entry.dart';
import '../database/app_database.dart';

class BasalRepository {
  BasalRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<BasalEntry>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('basal_entries', orderBy: 'timestamp DESC');
    return rows.map(BasalEntry.fromMap).toList();
  }

  Future<void> insert(BasalEntry entry) async {
    final db = await _appDatabase.database;
    await db.insert('basal_entries', entry.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('basal_entries', where: 'id = ?', whereArgs: [id]);
  }
}
