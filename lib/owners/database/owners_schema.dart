// lib/owners/database/owners_schema.dart
import 'package:sqflite/sqflite.dart';

class OwnersSchema {
  static Future<void> ensure(Database db) async {
    // الحالة الحالية لكل وحدة
    await db.execute('''
      CREATE TABLE IF NOT EXISTS owner_state(
        unit_id      INTEGER PRIMARY KEY,
        is_present   INTEGER NOT NULL DEFAULT 0,
        last_entry   TEXT,
        last_exit    TEXT,
        car_plates   TEXT,     -- نص مفصول بـ | للحفاظ على البساطة
        companions   INTEGER,  -- عدد المرافقين (اختياري)
        updated_at   TEXT NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');

    // سجل الأحداث
    await db.execute('''
      CREATE TABLE IF NOT EXISTS owner_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        unit_id  INTEGER NOT NULL,
        op       TEXT NOT NULL,     -- enter | exit | unit_check
        at       TEXT NOT NULL DEFAULT (datetime('now')),
        by_whom  TEXT,              -- "الموظف" / "السيستم (دخول مالك)" ..الخ
        cars     TEXT,              -- "س ص 123|..." اختياري
        alerts   TEXT,              -- "باب مفتوح|..." اختياري
        notes    TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_owner_logs_unit_at ON owner_logs(unit_id, at DESC);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_owner_logs_op ON owner_logs(op);',
    );
  }
}
