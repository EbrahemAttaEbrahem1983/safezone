import 'package:sqflite/sqflite.dart';
import 'app_database.dart';
import '../models/sector.dart';

class SectorDao {
  Database get _db => UnitsDatabase.instance.db;

  Future<List<MainSector>> mains() async {
    final rows = await _db.query(
      'sectors_main',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(MainSector.fromMap).toList();
  }

  Future<List<SubSector>> subsByMain(int mainId) async {
    final rows = await _db.query(
      'sectors_sub',
      where: 'main_id = ?',
      whereArgs: [mainId],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(SubSector.fromMap).toList();
  }

  // ✅ جديد: نحتاجه لاستنتاج الأب عند اختيار فرعي
  Future<SubSector?> getSubById(int id) async {
    final rows = await _db.query(
      'sectors_sub',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SubSector.fromMap(rows.first);
  }

  // موجودة لو احتجتها
  Future<MainSector?> findMainByName(String name) async {
    final rows = await _db.query(
      'sectors_main',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return MainSector.fromMap(rows.first);
  }

  Future<SubSector?> findSubByName(int mainId, String name) async {
    final rows = await _db.query(
      'sectors_sub',
      where: 'main_id = ? AND name = ?',
      whereArgs: [mainId, name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SubSector.fromMap(rows.first);
  }

  Future<int> insertMain(String name) =>
      _db.insert('sectors_main', {'name': name.trim()});

  Future<int> updateMain(int id, String name) => _db.update(
        'sectors_main',
        {'name': name.trim()},
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<int> deleteMain(int id) =>
      _db.delete('sectors_main', where: 'id = ?', whereArgs: [id]);

  Future<int> insertSub(int mainId, String name) =>
      _db.insert('sectors_sub', {'main_id': mainId, 'name': name.trim()});

  Future<int> updateSub(int id, String name) => _db.update(
        'sectors_sub',
        {'name': name.trim()},
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<int> deleteSub(int id) =>
      _db.delete('sectors_sub', where: 'id = ?', whereArgs: [id]);
}
