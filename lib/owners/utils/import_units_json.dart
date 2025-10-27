// lib/owners/utils/import_units_json.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../units/database/app_database.dart';
import '../database/owners_dao.dart';
import '../database/owners_schema.dart';

class OwnersJsonImporter {
  final dao = OwnersDao();

  Future<Map<String, int>> importFromAssets(String assetPath) async {
    final db = UnitsDatabase.instance.db;
    await OwnersSchema.ensure(db);
    final raw = await rootBundle.loadString(assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    int updated = 0, logs = 0, skipped = 0;

    await db.transaction((txn) async {
      for (final m in list) {
        final unitName = (m['unit_id'] as String).trim().toUpperCase();
        final unitId = await dao.unitIdByUpperName(unitName);
        if (unitId == null) {
          skipped++;
          continue;
        }

        // presence block
        final owner = (m['owner'] ?? {}) as Map<String, dynamic>;
        final isPresent = (owner['is_present'] ?? false) ? true : false;
        final lastEntry = (owner['last_entry'] as String?)?.trim();
        final lastExit = (owner['last_exit'] as String?)?.trim();
        final plates = (owner['car_plates'] as List?)
            ?.map((e) => '$e')
            .toList();

        await dao.setPresence(
          unitId: unitId,
          isPresent: isPresent,
          lastEntry: (lastEntry?.isEmpty ?? true) ? null : lastEntry,
          lastExit: (lastExit?.isEmpty ?? true) ? null : lastExit,
          carPlates: plates,
        );
        updated++;

        // events -> logs
        final events = (m['events'] as List? ?? const []);
        for (final e in events) {
          final mm = e as Map<String, dynamic>;
          final t = (mm['type'] as String).trim();
          final dt = (mm['date'] as String?)?.trim();
          final by = (mm['by'] as String?)?.trim();
          if (dt == null || dt.isEmpty) continue;
          await dao.addLog(
            unitId: unitId,
            op: t,
            byWhom: by,
            at: DateTime.tryParse(dt),
          );
          logs++;
        }
      }
    });

    return {
      'updated_units': updated,
      'logs_imported': logs,
      'skipped_units': skipped,
    };
  }
}
