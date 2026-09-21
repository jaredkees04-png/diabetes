import '../../domain/models/bolus_entry.dart';
import '../database/app_database.dart';

class BolusRepository {
  BolusRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<BolusEntry>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('bolus_entries', orderBy: 'timestamp DESC');
    return rows.map(BolusEntry.fromMap).toList();
  }

  Future<void> insert(BolusEntry entry) async {
    final db = await _appDatabase.database;
    await db.insert('bolus_entries', entry.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('bolus_entries', where: 'id = ?', whereArgs: [id]);
  }
}
