// lib/owners/database/owners_dao.dart
import 'package:sqflite/sqflite.dart';
import '../../units/database/app_database.dart';

class OwnersDao {
  Database get _db => UnitsDatabase.instance.db;

  // --- مساعدات للوحدات ---
  Future<int?> unitIdByUpperName(String upper) async {
    final rows = await _db.query(
      'units',
      columns: ['id'],
      where: 'UPPER(name)=?',
      whereArgs: [upper],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int;
  }

  // يرجّع السجل آخر X ساعة مع اسم الوحدة
  Future<List<Map<String, Object?>>> listLogsSince({required int hours}) async {
    final from = DateTime.now()
        .subtract(Duration(hours: hours))
        .toIso8601String();

    final sql = '''
    SELECT l.*, u.name AS unit_name
    FROM owner_logs l
    JOIN units u ON u.id = l.unit_id
    WHERE l.at >= ?
    ORDER BY l.at DESC
  ''';

    return _db.rawQuery(sql, [from]);
  }

  Future<List<String>> unitNames() async {
    final rows = await _db.query(
      'units',
      columns: ['name'],
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map((e) => (e['name'] as String)).toList();
  }

  // --- تحديث حالة الوحدة ---
  Future<void> setPresence({
    required int unitId,
    required bool isPresent,
    String? lastEntry,
    String? lastExit,
    List<String>? carPlates,
    int? companions,
  }) async {
    final data = <String, Object?>{
      'unit_id': unitId,
      'is_present': isPresent ? 1 : 0,
      'last_entry': lastEntry,
      'last_exit': lastExit,
      'car_plates': carPlates == null ? null : carPlates.join('|'),
      'companions': companions,
      'updated_at': DateTime.now().toIso8601String(),
    };
    // UPSERT
    final count = await _db.update(
      'owner_state',
      data,
      where: 'unit_id=?',
      whereArgs: [unitId],
    );
    if (count == 0) {
      await _db.insert(
        'owner_state',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _db.update(
      'units',
      {'status': isPresent ? 'occupied' : 'vacant'},
      where: 'id=?',
      whereArgs: [unitId],
    );
  }

  // --- تسجيل حدث ---
  Future<int> addLog({
    required int unitId,
    required String op, // enter|exit|unit_check
    String? byWhom,
    List<String>? cars,
    List<String>? alerts,
    String? notes,
    DateTime? at,
  }) async {
    return _db.insert('owner_logs', {
      'unit_id': unitId,
      'op': op,
      'by_whom': byWhom,
      'cars': cars?.join('|'),
      'alerts': alerts?.join('|'),
      'notes': notes,
      'at': (at ?? DateTime.now()).toIso8601String(),
    });
  }

  // --- قراءة السجل لِوحدة (Ledger) ---
  Future<List<Map<String, Object?>>> unitLedger(
    int unitId, {
    int limit = 200,
  }) async {
    return _db.query(
      'owner_logs',
      where: 'unit_id=?',
      whereArgs: [unitId],
      orderBy: 'at DESC',
      limit: limit,
    );
  }

  // --- إحصائيات مختصرة ---
  Future<Map<String, int>> presenceStats() async {
    final present =
        Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM owner_state WHERE is_present=1',
          ),
        ) ??
        0;
    final away =
        Sqflite.firstIntValue(
          await _db.rawQuery(
            'SELECT COUNT(*) FROM owner_state WHERE is_present=0',
          ),
        ) ??
        0;
    final activeUnits =
        Sqflite.firstIntValue(
          await _db.rawQuery('SELECT COUNT(*) FROM owner_state'),
        ) ??
        0;
    return {'present': present, 'away': away, 'active_units': activeUnits};
  }

  Future<List<Map<String, Object?>>> listPresenceRows({bool? isPresent}) async {
    final where = <String>[];
    final args = <Object?>[];
    if (isPresent != null) {
      where.add('s.is_present=?');
      args.add(isPresent ? 1 : 0);
    }
    final sql =
        '''
      SELECT u.id AS unit_id, u.name AS unit_name, s.is_present, s.last_entry, s.last_exit, s.car_plates, s.companions
      FROM owner_state s
      JOIN units u ON u.id = s.unit_id
      ${where.isEmpty ? '' : 'WHERE ' + where.join(' AND ')}
      ORDER BY u.name COLLATE NOCASE ASC
    ''';
    return _db.rawQuery(sql, args);
  }
}
