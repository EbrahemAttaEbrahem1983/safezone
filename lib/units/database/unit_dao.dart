import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import '../models/unit.dart';

class UnitDao {
  Database get _db => UnitsDatabase.instance.db;

  // ==================== CRUD ====================

  Future<int> insert(Unit u) async {
    return _db.insert('units', {
      'name': u.name,
      'main_id': u.mainSectorId,
      'sub_id': u.subSectorId,
      'is_planted': u.isPlanted ? 1 : 0,
      'is_furnished': u.isFurnished ? 1 : 0,
      'has_installments': u.hasInstallments ? 1 : 0,
      'owner_id': u.ownerId,
      'status': u.status,
      'notes': u.notes,
    });
  }

  Future<int> update(Unit u) async {
    return _db.update(
      'units',
      {
        'name': u.name,
        'main_id': u.mainSectorId,
        'sub_id': u.subSectorId,
        'is_planted': u.isPlanted ? 1 : 0,
        'is_furnished': u.isFurnished ? 1 : 0,
        'has_installments': u.hasInstallments ? 1 : 0,
        'owner_id': u.ownerId,
        'status': u.status,
        'notes': u.notes,
      },
      where: 'id = ?',
      whereArgs: [u.id],
    );
  }

  Future<int> delete(int id) async {
    return _db.delete('units', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsert(Unit u) async {
    if (u.id == null) {
      await insert(u);
    } else {
      await update(u);
    }
  }

  // ==================== استعلامات العرض ====================

  /// قائمة موحّدة مع أسماء الرئيسي/الفرعي (تتأثر بالفلاتر)
  Future<List<Map<String, Object?>>> listJoined({
    int? mainId,
    int? subId,
    String? search,
    String sort = 'newest', // name_asc | name_desc | newest
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (mainId != null) {
      where.add('u.main_id = ?');
      args.add(mainId);
    }
    if (subId != null) {
      where.add('u.sub_id = ?');
      args.add(subId);
    }
    if (search != null && search.trim().isNotEmpty) {
      where.add('u.name LIKE ?');
      args.add('%${search.trim()}%');
    }

    String orderBy;
    switch (sort) {
      case 'name_asc':
        orderBy = 'u.name COLLATE NOCASE ASC';
        break;
      case 'name_desc':
        orderBy = 'u.name COLLATE NOCASE DESC';
        break;
      default:
        orderBy = 'u.id DESC';
    }

    final sql = '''
      SELECT u.*,
             m.name AS main_name,
             s.name AS sub_name
      FROM units u
      JOIN sectors_main m ON m.id = u.main_id
      JOIN sectors_sub  s ON s.id = u.sub_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      ORDER BY $orderBy
    ''';

    return _db.rawQuery(sql, args);
  }

  // ==================== إحصاءات (بالأسماء) ====================

  /// تجميع بعد الفلاتر حسب اسم الرئيسي (لو أردتها متأثرة بالفلاتر).
  Future<List<Map<String, Object?>>> statsPerMain({
    int? mainId,
    int? subId,
    String? search,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (mainId != null) { where.add('u.main_id = ?'); args.add(mainId); }
    if (subId != null) { where.add('u.sub_id = ?'); args.add(subId); }
    if (search != null && search.trim().isNotEmpty) {
      where.add('u.name LIKE ?');
      args.add('%${search.trim()}%');
    }

    final sql = '''
      SELECT m.name AS main_name, COUNT(*) AS c
      FROM units u
      JOIN sectors_main m ON m.id = u.main_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      GROUP BY u.main_id
      ORDER BY m.name COLLATE NOCASE ASC
    ''';

    return _db.rawQuery(sql, args);
  }

  /// تجميع فرعيات داخل كل رئيسي (بالأسماء – اختياري).
  Future<List<Map<String, Object?>>> statsPerSubByMain({
    int? mainId,
    int? subId,
    String? search,
  }) async {
    final where = <String>[];
    final args = <Object?>[];

    if (mainId != null) { where.add('u.main_id = ?'); args.add(mainId); }
    if (subId != null) { where.add('u.sub_id = ?'); args.add(subId); }
    if (search != null && search.trim().isNotEmpty) {
      where.add('u.name LIKE ?');
      args.add('%${search.trim()}%');
    }

    final sql = '''
      SELECT m.name AS main_name, s.name AS sub_name, COUNT(*) AS c
      FROM units u
      JOIN sectors_main m ON m.id = u.main_id
      JOIN sectors_sub  s ON s.id = u.sub_id
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
      GROUP BY u.main_id, u.sub_id
      ORDER BY m.name COLLATE NOCASE ASC, s.name COLLATE NOCASE ASC
    ''';

    return _db.rawQuery(sql, args);
  }

  // ==================== إحصاءات (بالمفاتيح الرقمية) ====================

  /// ✅ تجميع بالرئيسي باستخدام الـID لضمان التطابق.
  Future<List<Map<String, Object?>>> statsPerMainById() async {
    final sql = '''
      SELECT u.main_id AS mid, COUNT(*) AS c
      FROM units u
      GROUP BY u.main_id
      ORDER BY mid ASC
    ''';
    return _db.rawQuery(sql);
  }

  /// ✅ تجميع: فرعيات داخل كل رئيسي (بالـID للرئيسي + اسم الفرعي).
  Future<List<Map<String, Object?>>> statsPerSubByMainById() async {
    final sql = '''
      SELECT u.main_id AS mid, s.name AS sub_name, COUNT(*) AS c
      FROM units u
      JOIN sectors_sub s ON s.id = u.sub_id
      GROUP BY u.main_id, u.sub_id
      ORDER BY mid ASC, s.name COLLATE NOCASE ASC
    ''';
    return _db.rawQuery(sql);
  }

  /// عدّاد عام (بدون/مع فلاتر).
  Future<int> countAll({int? mainId, int? subId, String? search}) async {
    final where = <String>[];
    final args = <Object?>[];

    if (mainId != null) { where.add('main_id = ?'); args.add(mainId); }
    if (subId != null) { where.add('sub_id = ?'); args.add(subId); }
    if (search != null && search.trim().isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%${search.trim()}%');
    }

    final sql = '''
      SELECT COUNT(*) AS c
      FROM units
      ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
    ''';

    final res = await _db.rawQuery(sql, args);
    return (res.first['c'] as int?) ?? 0;
  }
}
