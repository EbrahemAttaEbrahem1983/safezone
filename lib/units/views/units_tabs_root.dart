// lib/units/views/units_tabs_root.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'views_main_tab.dart';
import 'views_sub_tab.dart';
import 'views_units_tab.dart';

// الاستيراد وإعادة التحميل
import '../utils/import_json.dart';
import '../database/sector_dao.dart';
import '../database/unit_dao.dart';
import '../database/app_database.dart';
import '../controllers/sectors_controller.dart';
import '../controllers/units_controller.dart';

class UnitsTabsRoot extends StatelessWidget {
  const UnitsTabsRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: AppBar(
            backgroundColor: cs.surface,
            iconTheme: IconThemeData(color: cs.onSurface),
            title: Text(
              'إدارة القطاعات والوحدات',
              style: TextStyle(color: cs.onSurface),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: cs.surfaceVariant,
                    child: const TabBar(
                      tabs: [
                        Tab(
                          child: Text('الرئيسية',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14)),
                        ),
                        Tab(
                          child: Text('الفرعية',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14)),
                        ),
                        Tab(
                          child: Text('الوحدات',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  // خط سفلي رفيع للفصل البصري
                  Divider(height: 1, color: cs.onSurface.withOpacity(0.12)),
                ],
              ),
            ),
            // actions: [
            //   IconButton(
            //     tooltip: 'استيراد JSON',
            //     icon: Icon(Icons.file_download, color: cs.onSurface),
            //     onPressed: () => _importFromJson(context),
            //   ),
            // ],
          ),
          body: const TabBarView(
            children: [MainSectorsTab(), SubSectorsTab(), UnitsTab()],
          ),
        ),
      ),
    );
  }

  Future<void> _importFromJson(BuildContext context) async {
    try {
      _showBusy(context, 'جارِ الاستيراد…');
      final res = await UnitsJsonImporter(
        sectorDao: Get.find<SectorDao>(),
        unitDao: Get.find<UnitDao>(),
      ).importFromAssets(
        assetPath: 'assets/seed/units_export.json',
        wipe: true,
      );

      if (context.mounted) Navigator.pop(context);

      if (res.ok) {
        if (Get.isRegistered<SectorsController>()) {
          final s = Get.find<SectorsController>();
          await s.loadMains();
          if (Get.isRegistered<UnitsController>()) {
            final u = Get.find<UnitsController>();
            u.mainId.value = s.mainId.value;
            u.subId.value = s.subId.value;
            await u.load();
          }
        }
        if (context.mounted) {
          _toast(
            context,
            'تم الاستيراد بنجاح • رئيسي: ${res.mains} • فرعي: ${res.subs} • وحدات: ${res.units}',
          );
        }
      } else {
        if (context.mounted) {
          _toast(context, 'تعذّر الاستيراد: ${res.error ?? 'غير معروف'}',
              isErr: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        _toast(context, 'تعذّر الاستيراد: $e', isErr: true);
      }
    }
  }

  static Future<String?> _ask(BuildContext ctx, String title) async {
    final t = TextEditingController();
    return showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        final cs = Theme.of(dialogCtx).colorScheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cs.surfaceVariant,
            title: Text(title, style: TextStyle(color: cs.onSurface)),
            content: TextField(
              controller: t,
              style: TextStyle(color: cs.onSurface),
              obscureText: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, t.text.trim()),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBusy(BuildContext ctx, String msg) {
    showDialog<void>(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final cs = Theme.of(dialogCtx).colorScheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cs.surfaceVariant,
            content: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    // نثبّت اللون ليتوافق مع الأبيض/الأسود
                    valueColor:
                        AlwaysStoppedAnimation<Color>(cs.onSurface),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    msg,
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toast(BuildContext ctx, String msg, {bool isErr = false}) {
    final cs = Theme.of(ctx).colorScheme;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        backgroundColor:
            isErr ? Colors.red.shade700 : cs.onSurface.withOpacity(0.87),
        content: Text(msg, textDirection: TextDirection.rtl),
      ),
    );
  }
}
