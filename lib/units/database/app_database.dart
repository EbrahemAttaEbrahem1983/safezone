import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../utils/import_json.dart'; // ✅
import 'sector_dao.dart'; // ✅
import 'unit_dao.dart'; // ✅

class UnitsDatabase {
  UnitsDatabase._();
  static final UnitsDatabase instance = UnitsDatabase._();
  Database? _db;
  Database get db => _db!;

  // lib/units/database/app_database.dart
  // lib/units/database/app_database.dart
  // داخل class UnitsDatabase
  Future<void> init() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'safe_zone_units.db'),
      version: 1,
      onConfigure: (d) async => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: (d, v) async => _createSchema(d),
    );
    await _maybeImportOrSeed(); // ← مهم
  }

  Future<void> _maybeImportOrSeed() async {
    final cnt =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM sectors_main'),
        ) ??
        0;
    if (cnt > 0) return;

    try {
      final res =
          await UnitsJsonImporter(
            sectorDao: SectorDao(),
            unitDao: UnitDao(),
          ).importFromAssets(
            assetPath: 'assets/seed/units_export.json',
            wipe: true,
          );

      if (res.hasData) return; // تم الاستيراد فعلاً
    } catch (_) {
      // تجاهل وأكمل بالـ seed
    }

    await _seed(db); // fallback
  }

  Future<void> resetAndReseedForDev() async {
    final path = await getDatabasesPath();
    await deleteDatabase(p.join(path, 'safe_zone_units.db'));
    await init();
  }

  static Future<void> _createSchema(Database d) async {
    await d.execute('''
      CREATE TABLE sectors_main(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');

    await d.execute('''
      CREATE TABLE sectors_sub(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        main_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(main_id) REFERENCES sectors_main(id)
          ON DELETE RESTRICT ON UPDATE CASCADE
      );
    ''');

    await d.execute('''
      CREATE TABLE units(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        main_id INTEGER NOT NULL,
        sub_id INTEGER NOT NULL,
        is_planted INTEGER NOT NULL DEFAULT 0,
        is_furnished INTEGER NOT NULL DEFAULT 0,
        has_installments INTEGER NOT NULL DEFAULT 0,
        owner_id INTEGER,
        status TEXT NOT NULL DEFAULT "vacant",
        notes TEXT,
        FOREIGN KEY(main_id) REFERENCES sectors_main(id)
          ON DELETE RESTRICT ON UPDATE CASCADE,
        FOREIGN KEY(sub_id) REFERENCES sectors_sub(id)
          ON DELETE RESTRICT ON UPDATE CASCADE
      );
    ''');

    await d.execute('CREATE INDEX idx_units_main ON units(main_id);');
    await d.execute('CREATE INDEX idx_units_sub ON units(sub_id);');
    await d.execute('CREATE INDEX idx_units_name ON units(name);');
  }

  // ========= logic: import JSON or fallback seed =========
  // Future<void> _maybeImportOrSeed() async {
  //   // لو عندك بيانات أصلاً، خلاص
  //   final cnt = Sqflite.firstIntValue(
  //         await db.rawQuery('SELECT COUNT(*) FROM sectors_main'),
  //       ) ??
  //       0;
  //   if (cnt > 0) return;

  //   try {
  //     final importer = UnitsJsonImporter(
  //       sectorDao: SectorDao(),
  //       unitDao: UnitDao(),
  //     );

  //     final res = await importer.importFromAssets(
  //       assetPath: 'assets/seed/units_export.json',
  //       wipe: true, // امسح القديم قبل الإدراج
  //     );

  //     // هنا كانت الغلطة — افحص أرقام النتيجة بدل ما تتعامل كـ bool
  //     if (res.mains > 0 || res.subs > 0 || res.units > 0) {
  //       return; // تم الاستيراد بنجاح
  //     }
  //   } catch (_) {
  //     // تجاهل الخطأ وكمّل بـ seed
  //   }

  //   // لو وصلنا هنا يبقى الاستيراد فشل/فاضي ⇒ زرع بيانات افتراضية
  //   await _seed(db);
  // }
  static Future<void> _seed(Database d) async {
    for (final name in ['القطاع الشرقي', 'القطاع الغربي']) {
      await d.insert('sectors_main', {'name': name});
    }
    final mains = await d.query('sectors_main', orderBy: 'id ASC');
    for (final m in mains) {
      final id = m['id'] as int;
      for (var i = 1; i <= 3; i++) {
        await d.insert('sectors_sub', {'main_id': id, 'name': 'منصّة $i'});
      }
    }
    final subs = await d.query('sectors_sub', orderBy: 'id ASC');
    if (subs.isNotEmpty) {
      await d.insert('units', {
        'name': 'UNIT 2',
        'main_id': mains.first['id'],
        'sub_id': subs.first['id'],
        'is_planted': 1,
        'status': 'vacant',
      });
      await d.insert('units', {
        'name': 'VILLA 3',
        'main_id': mains.last['id'],
        'sub_id': subs.last['id'],
        'is_furnished': 1,
        'status': 'occupied',
      });
    }
  }
}
