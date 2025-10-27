import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/sector_dao.dart';
import '../database/unit_dao.dart';

class ImportResult {
  final int mains;
  final int subs;
  final int units;
  final String? error;
  const ImportResult({
    this.mains = 0,
    this.subs = 0,
    this.units = 0,
    this.error,
  });

  int get total => mains + subs + units;
  bool get ok => total > 0 && error == null;
  bool get hasData => total > 0;
}

class UnitsJsonImporter {
  final SectorDao sectorDao;
  final UnitDao unitDao;
  UnitsJsonImporter({required this.sectorDao, required this.unitDao});

  /// يقرأ من الأصول ويستورد
  Future<ImportResult> importFromAssets({
    String assetPath = 'assets/seed/units_export.json',
    bool wipe = true,
  }) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final dynamic decoded = jsonDecode(raw);

      // نحدّد شكل المصدر: خريطة {mains/subs/units} أو قائمة من الوحدات
      if (decoded is Map<String, dynamic>) {
        final mains = (decoded['mains'] as List? ?? const [])
            .cast<Map<String, dynamic>>();
        final subs = (decoded['subs'] as List? ?? const [])
            .cast<Map<String, dynamic>>();
        final units = (decoded['units'] as List? ?? const [])
            .cast<Map<String, dynamic>>();
        return await _importStructured(
          mains: mains,
          subs: subs,
          units: units,
          wipe: wipe,
        );
      } else if (decoded is List) {
        final rows = decoded.cast<Map<String, dynamic>>();
        return await _importFlatList(rows, wipe: wipe);
      } else {
        return const ImportResult(error: 'صيغة JSON غير معروفة');
      }
    } catch (e) {
      return ImportResult(error: e.toString());
    }
  }

  /// مصدر على شكل { mains/subs/units }
  Future<ImportResult> _importStructured({
    required List<Map<String, dynamic>> mains,
    required List<Map<String, dynamic>> subs,
    required List<Map<String, dynamic>> units,
    required bool wipe,
  }) async {
    final db = UnitsDatabase.instance.db;
    int mCnt = 0, sCnt = 0, uCnt = 0;

    await db.transaction((txn) async {
      if (wipe) {
        await txn.delete('units');
        await txn.delete('sectors_sub');
        await txn.delete('sectors_main');
      }

      // main
      final mainIdByName = <String, int>{};
      for (final m in mains) {
        final name = (m['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        final id = await txn.insert('sectors_main', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        if (id == 0) {
          final row = await txn.query(
            'sectors_main',
            where: 'name = ?',
            whereArgs: [name],
            limit: 1,
          );
          if (row.isNotEmpty) mainIdByName[name] = row.first['id'] as int;
        } else {
          mainIdByName[name] = id;
          mCnt++;
        }
      }

      // sub
      final subKeyId = <String, int>{}; // key: main::sub
      for (final s in subs) {
        final mainName = (s['main'] as String?)?.trim();
        final subName = (s['name'] as String?)?.trim();
        if ((mainName == null) || (subName == null)) continue;
        final mid = mainIdByName[mainName];
        if (mid == null) continue;

        final id = await txn.insert('sectors_sub', {
          'main_id': mid,
          'name': subName,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        final key = '$mainName::$subName';
        if (id == 0) {
          final row = await txn.query(
            'sectors_sub',
            where: 'main_id = ? AND name = ?',
            whereArgs: [mid, subName],
            limit: 1,
          );
          if (row.isNotEmpty) subKeyId[key] = row.first['id'] as int;
        } else {
          subKeyId[key] = id;
          sCnt++;
        }
      }

      // units
      for (final u in units) {
        final mainName = (u['main'] as String?)?.trim();
        final subName = (u['sub'] as String?)?.trim();
        final name = (u['name'] as String?)?.trim();
        if (mainName == null || subName == null || name == null) continue;

        final mid = mainIdByName[mainName];
        final sid = subKeyId['$mainName::$subName'];
        if (mid == null || sid == null) continue;

        await txn.insert('units', {
          'name': name,
          'main_id': mid,
          'sub_id': sid,
          'is_planted': ((u['isPlanted'] as bool?) ?? false) ? 1 : 0,
          'is_furnished': ((u['isFurnished'] as bool?) ?? false) ? 1 : 0,
          'has_installments': ((u['hasInstallments'] as bool?) ?? false)
              ? 1
              : 0,
          'owner_id': u['ownerId'] as int?,
          'status': (u['status'] as String?)?.trim() ?? 'vacant',
          'notes': u['notes'] as String?,
        });
        uCnt++;
      }
    });

    return ImportResult(mains: mCnt, subs: sCnt, units: uCnt);
  }

  /// مصدر على شكل قائمة وحدات (كما في الملف اللي أرسلته)
  Future<ImportResult> _importFlatList(
    List<Map<String, dynamic>> rows, {
    required bool wipe,
  }) async {
    final db = UnitsDatabase.instance.db;
    int mCnt = 0, sCnt = 0, uCnt = 0;

    await db.transaction((txn) async {
      if (wipe) {
        await txn.delete('units');
        await txn.delete('sectors_sub');
        await txn.delete('sectors_main');
      }

      final mainIdByName = <String, int>{};
      final subKeyId = <String, int>{};

      Future<int> ensureMain(String name) async {
        name = name.trim();
        if (mainIdByName.containsKey(name)) return mainIdByName[name]!;
        final id = await txn.insert('sectors_main', {
          'name': name,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        if (id == 0) {
          final row = await txn.query(
            'sectors_main',
            where: 'name = ?',
            whereArgs: [name],
            limit: 1,
          );
          final got = row.first['id'] as int;
          mainIdByName[name] = got;
          return got;
        } else {
          mainIdByName[name] = id;
          mCnt++;
          return id;
        }
      }

      Future<int> ensureSub(int mid, String mainName, String subName) async {
        final key = '${mainName.trim()}::${subName.trim()}';
        if (subKeyId.containsKey(key)) return subKeyId[key]!;
        final id = await txn.insert('sectors_sub', {
          'main_id': mid,
          'name': subName.trim(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        if (id == 0) {
          final row = await txn.query(
            'sectors_sub',
            where: 'main_id = ? AND name = ?',
            whereArgs: [mid, subName.trim()],
            limit: 1,
          );
          final got = row.first['id'] as int;
          subKeyId[key] = got;
          return got;
        } else {
          subKeyId[key] = id;
          sCnt++;
          return id;
        }
      }

      for (final r in rows) {
        final mainName = (r['sector'] ?? 'غير مُحدّد').toString();
        final subName = (r['platform'] ?? 'بدون منصّة').toString();
        final unitName = (r['unit_id'] ?? r['_id'] ?? '').toString().trim();
        if (unitName.isEmpty) continue;

        final mid = await ensureMain(mainName);
        final sid = await ensureSub(mid, mainName, subName);

        // اشتقاق الحالة
        String status = 'vacant';
        if (r['under_construction'] == true) {
          status = 'under_construction';
        } else if (r['rented'] == true) {
          status = 'rented';
        } else {
          final owner = (r['owner'] as Map?) ?? const {};
          if (owner['is_present'] == true) status = 'occupied';
        }

        await txn.insert('units', {
          'name': unitName,
          'main_id': mid,
          'sub_id': sid,
          'is_planted': (r['planted'] == true) ? 1 : 0,
          'is_furnished': (r['furnished'] == true) ? 1 : 0,
          'has_installments': 0,
          'owner_id': null,
          'status': status,
          'notes': null,
        });
        uCnt++;
      }
    });

    return ImportResult(mains: mCnt, subs: sCnt, units: uCnt);
  }
}
