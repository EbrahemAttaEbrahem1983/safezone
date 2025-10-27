// lib/units/views/views_main_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/colors.dart';
import '../controllers/sectors_controller.dart';

class MainSectorsTab extends StatefulWidget {
  const MainSectorsTab({super.key});
  @override
  State<MainSectorsTab> createState() => _MainSectorsTabState();
}

class _MainSectorsTabState extends State<MainSectorsTab> {
  late final SectorsController c;
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    c = Get.find<SectorsController>();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  textDirection: TextDirection.rtl,
                  decoration: _input(context, 'اسم قطاع رئيسي جديد'),
                  style: TextStyle(color: cs.onSurface),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_name.text.trim().isNotEmpty) {
                    await c.addMain(_name.text.trim());
                    _name.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.secondaryContainer,
                  foregroundColor: cs.onSecondaryContainer,
                ),
                child: const Text('إضافة'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: c.mains.length,
                itemBuilder: (_, i) {
                  final m = c.mains[i];
                  return Card(
                    color: cs.surfaceVariant,
                    child: ListTile(
                      title: Text(m.name, style: TextStyle(color: cs.onSurface)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final t = await _editDialog(context, m.name);
                              if (t != null) await c.renameMain(m.id, t);
                            },
                            icon: Icon(Icons.edit, color: cs.onSurface.withOpacity(0.70)),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ok = await c.deleteMain(m.id);
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('لا يمكن حذف قطاع به فروع/وحدات', textDirection: TextDirection.rtl),
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.delete, color: cs.onSurface.withOpacity(0.70)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(BuildContext context, String h) => InputDecoration(
        hintText: h,
        hintTextDirection: TextDirection.rtl,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  static Future<String?> _editDialog(BuildContext ctx, String current) async {
    final t = TextEditingController(text: current);
    return showDialog<String>(
      context: ctx,
      builder: (dialogCtx) {
        final cs = Theme.of(dialogCtx).colorScheme;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: cs.surfaceVariant,
            title: Text('تعديل الاسم', style: TextStyle(color: cs.onSurface)),
            content: TextField(controller: t, style: TextStyle(color: cs.onSurface)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
              TextButton(onPressed: () => Navigator.pop(ctx, t.text.trim()), child: const Text('حفظ')),
            ],
          ),
        );
      },
    );
  }
}
