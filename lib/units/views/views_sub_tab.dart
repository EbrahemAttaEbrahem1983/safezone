// lib/units/views/views_sub_tab.dart  (SubSectorsTab)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sectors_controller.dart';

class SubSectorsTab extends StatefulWidget {
  const SubSectorsTab({super.key});
  @override
  State<SubSectorsTab> createState() => _SubSectorsTabState();
}

class _SubSectorsTabState extends State<SubSectorsTab> {
  final _name = TextEditingController();
  late final SectorsController c;

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
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: c.mainId.value,
                    isExpanded: true,
                    items: c.mains
                        .map(
                          (m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name, style: TextStyle(color: cs.onSurface)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) c.pickMain(v);
                    },
                    decoration: _input(context, 'اختر القطاع الرئيسي'),
                    dropdownColor: cs.surfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _name,
                    textDirection: TextDirection.rtl,
                    decoration: _input(context, 'اسم قطاع فرعي جديد (مثال: منصّة 1)'),
                    style: TextStyle(color: cs.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_name.text.trim().isNotEmpty && c.mainId.value != null) {
                      await c.addSub(c.mainId.value!, _name.text.trim());
                      _name.clear();
                    }
                  },
                  // زر Primary: خلفية primary ونص onPrimary
                  child: const Text('إضافة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: c.subs.length,
                itemBuilder: (_, i) {
                  final sItem = c.subs[i];
                  return Card(
                    color: cs.surfaceVariant,
                    child: ListTile(
                      title: Text(
                        sItem.name,
                        style: TextStyle(color: cs.onSurface),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final t = await _editDialog(context, sItem.name);
                              if (t != null) await c.renameSub(sItem.id, t);
                            },
                            icon: Icon(Icons.edit, color: cs.onSurface.withOpacity(0.70)),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ok = await c.deleteSub(sItem.id);
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'لا يمكن حذف قطاع فرعي مرتبط بوحدات',
                                      textDirection: TextDirection.rtl,
                                    ),
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

  InputDecoration _input(BuildContext context, String h) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: h,
      hintTextDirection: TextDirection.rtl,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.60)),
      filled: true,
      fillColor: cs.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

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
            actions: const [
              TextButton(child: Text('إلغاء'), onPressed: null), // Navigator.pop يضاف تلقائيًا بالضغط خارج الزر
            ],
          ),
        );
      },
    ).then((value) {
      // نرجّع القيمة يدويًا لأننا ما أضفنا أزراراً بإغلاق
      return t.text.trim().isEmpty ? null : t.text.trim();
    });
  }
}
