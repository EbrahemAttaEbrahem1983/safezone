import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/units_controller.dart';
import '../controllers/sectors_controller.dart';
import '../widgets/stats_panel.dart';
import '../widgets/unit_card.dart';
import '../models/unit.dart';
import 'unit_form_view.dart';

class UnitsTab extends StatefulWidget {
  const UnitsTab({super.key});
  @override
  State<UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<UnitsTab> {
  late final UnitsController c;
  late final SectorsController s;

  @override
  void initState() {
    super.initState();
    c = Get.find<UnitsController>();
    s = Get.find<SectorsController>();
    c.load(); // يحمّل "الجميع" مبدئيًا
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,

        floatingActionButton: FloatingActionButton(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          child: const Icon(Icons.add),
          onPressed: () async {
            final Unit? created = await Get.to(
              () => UnitFormView(
                preselectedMainId: s.mainId.value,
                preselectedSubId: s.subId.value,
              ),
            );
            if (created != null) {
              await c.upsert(created);
              await c.load();
            }
          },
        ),

        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ================== الفلاتر ==================
              Obx(() {
                final cs = Theme.of(context).colorScheme;

                final mainItems = <DropdownMenuItem<int?>>[
                  DropdownMenuItem(value: null, child: Text('الجميع', style: TextStyle(color: cs.onSurface))),
                  ...s.mains.map((m) => DropdownMenuItem<int?>(value: m.id, child: Text(m.name, style: TextStyle(color: cs.onSurface)))),
                ];

                final subItems = <DropdownMenuItem<int?>>[
                  DropdownMenuItem(value: null, child: Text('الجميع', style: TextStyle(color: cs.onSurface))),
                  ...s.subs.map((ss) => DropdownMenuItem<int?>(value: ss.id, child: Text(ss.name, style: TextStyle(color: cs.onSurface)))),
                ];

                return Row(
                  children: [
                    // الفرعي
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: s.subId.value,
                        decoration: _input(context, 'القطاع الفرعي'),
                        isExpanded: true,
                        dropdownColor: cs.surfaceVariant,
                        items: subItems,
                        onChanged: (v) async {
                          await s.pickSub(v);            // يضبط الأب تلقائيًا
                          c.setMain(s.mainId.value);
                          c.setSub(v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // الرئيسي
                    Expanded(
                      child: DropdownButtonFormField<int?>(
                        value: s.mainId.value,
                        decoration: _input(context, 'القطاع الرئيسي'),
                        isExpanded: true,
                        dropdownColor: cs.surfaceVariant,
                        items: mainItems,
                        onChanged: (v) async {
                          await s.pickMain(v); // يحمّل الفرعيات ويترك الفرعي = الجميع
                          c.setMain(v);
                          c.setSub(null);
                        },
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 12),

              // ================== البحث والفرز ==================
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: cs.onSurface),
                      decoration: _input(context, 'ابحث باسم الوحدة…'),
                      onChanged: c.setSearch,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    color: cs.surfaceVariant,
                    icon: Icon(Icons.sort, color: cs.onSurface),
                    onSelected: c.setSort,
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'name_asc',  child: Text('أبجدي (أ→ي)', style: TextStyle(color: cs.onSurface))),
                      PopupMenuItem(value: 'name_desc', child: Text('أبجدي (ي→أ)', style: TextStyle(color: cs.onSurface))),
                      PopupMenuItem(value: 'newest',    child: Text('الأحدث أولًا', style: TextStyle(color: cs.onSurface))),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ================== بطاقة الإحصاءات ==================
              Obx(() => StatsPanel(
                    totalAll: c.totalAll.value,
                    mainNamesById: c.mainNamesById,
                    perMainById: c.perMainById,
                    perSubsByMid: c.perSubsByMid,
                    selectedMainId: s.mainId.value, // null=الجميع
                  )),

              const SizedBox(height: 12),

              // ================== قائمة الوحدات ==================
              Expanded(
                child: Obx(() {
                  if (c.items.isEmpty) {
                    return Center(child: Text('لا توجد وحدات', style: TextStyle(color: cs.onSurface.withOpacity(0.70))));
                  }
                  return ListView.builder(
                    itemCount: c.items.length,
                    itemBuilder: (_, i) {
                      final it = c.items[i];
                      return UnitCard(
                        index: i,
                        title: it.unit.name,
                        mainName: it.mainName,
                        subName: it.subName,
                        status: it.unit.status,
                        onEdit: () async {
                          final Unit? updated = await Get.to(() => UnitFormView(existing: it.unit));
                          if (updated != null) { await c.upsert(updated); await c.load(); }
                        },
                        onDelete: () async { await c.remove(it.unit.id!); await c.load(); },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.55)),
      filled: true,
      fillColor: cs.surfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}
