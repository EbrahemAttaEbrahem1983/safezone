import 'package:flutter/material.dart';

/// بطاقة إحصاءات:
/// - تعرض الإجمالي العام.
/// - ثم قائمة القطاعات الرئيسية، وتحتهـا مباشرة القطاعات الفرعية مع عدّاد كل واحدة.
/// - تتكيّف مع الفلاتر: لو selectedMainId == null → تعرض الجميع، وإلا تعرض رئيسيًا واحدًا.
class StatsPanel extends StatelessWidget {
  const StatsPanel({
    super.key,
    required this.totalAll,
    required this.mainNamesById,  // mid -> name
    required this.perMainById,    // mid -> count
    required this.perSubsByMid,   // mid -> { subName -> count }
    required this.selectedMainId, // null = الجميع
  });

  final int totalAll;
  final Map<int, String> mainNamesById;
  final Map<int, int> perMainById;
  final Map<int, Map<String, int>> perSubsByMid;
  final int? selectedMainId;

  static const double _kStatsHeight = 260;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final mids = (selectedMainId == null)
        ? perMainById.keys.toList()
        : <int>[selectedMainId!];
    mids.sort();

    return Container(
      width: double.infinity,
      height: _kStatsHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 6), color: cs.onSurface.withOpacity(0.08))],
        border: Border.all(color: cs.outline.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text('إجمالي الوحدات', textAlign: TextAlign.right,
                style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700))),
              _CountBadge(value: totalAll.toString()),
              const SizedBox(width: 6),
              Icon(Icons.receipt_long, size: 18, color: cs.onSurface.withOpacity(0.70)),
            ],
          ),
          const SizedBox(height: 6),
          Divider(color: cs.onSurface.withOpacity(0.10), height: 10),

          Expanded(
            child: mids.isEmpty
                ? Center(child: Text('لا توجد بيانات إحصائية', style: TextStyle(color: cs.onSurface.withOpacity(0.6))))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: mids.length,
                    itemBuilder: (_, i) {
                      final mid = mids[i];
                      final mainName = mainNamesById[mid] ?? '—';
                      final mainCount = perMainById[mid] ?? 0;
                      final subs = (perSubsByMid[mid] ?? const {}).entries.toList()
                        ..sort((a,b) => a.key.compareTo(b.key));

                      return _MainSection(
                        cs: cs,
                        mainName: mainName,
                        mainCount: mainCount,
                        subs: subs,
                        isLast: i == mids.length - 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MainSection extends StatelessWidget {
  const _MainSection({
    required this.cs,
    required this.mainName,
    required this.mainCount,
    required this.subs,
    required this.isLast,
  });

  final ColorScheme cs;
  final String mainName;
  final int mainCount;
  final List<MapEntry<String, int>> subs;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // سطر الرئيسي
        Row(
          children: [
            Expanded(child: Text(mainName, textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700))),
            _CountBadge(value: mainCount.toString()),
            const SizedBox(width: 6),
            Icon(Icons.maps_home_work_outlined, size: 18, color: cs.onSurface.withOpacity(0.60)),
          ],
        ),
        const SizedBox(height: 6),

        // الفرعيات أسفل الرئيسي
        if (subs.isEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text('لا توجد قطاعات فرعية', style: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 12)),
          )
        else
          Column(
            children: [
              for (final e in subs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 14),
                  child: Row(
                    children: [
                      Expanded(child: Text(e.key, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurface.withOpacity(0.75)))),
                      _CountBadge(value: e.value.toString()),
                      const SizedBox(width: 6),
                      Icon(Icons.home_work_outlined, size: 18, color: cs.onSurface.withOpacity(0.55)),
                    ],
                  ),
                ),
            ],
          ),

        if (!isLast) ...[
          const SizedBox(height: 6),
          Divider(color: cs.onSurface.withOpacity(0.08), height: 10),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value});
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(999)),
      child: Text(value, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
    );
  }
}
