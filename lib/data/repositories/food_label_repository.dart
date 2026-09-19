import '../../domain/models/food_label.dart';
import '../database/app_database.dart';

class FoodLabelRepository {
  FoodLabelRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<List<FoodLabel>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query('food_labels', orderBy: 'created_at DESC');
    return rows.map(FoodLabel.fromMap).toList();
  }

  Future<void> insert(FoodLabel label) async {
    final db = await _appDatabase.database;
    await db.insert('food_labels', label.toMap());
  }

  Future<void> delete(String id) async {
    final db = await _appDatabase.database;
    await db.delete('food_labels', where: 'id = ?', whereArgs: [id]);
  }
}
