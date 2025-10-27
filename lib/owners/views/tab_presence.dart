// lib/owners/views/tab_presence.dart
import 'package:flutter/material.dart';
import '../controllers/presence_controller.dart';
import 'package:get/get.dart';

class PresenceNowTab extends StatefulWidget {
  const PresenceNowTab({super.key});
  @override
  State<PresenceNowTab> createState() => _PresenceNowTabState();
}

class _PresenceNowTabState extends State<PresenceNowTab> {
  final c = Get.put(PresenceController());

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final s = c.stats;
      final rows = c.rows;

      return Column(
        children: [
          // لو الشاشة ضيقة، الـWrap يمنع أي Overflow
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatCard(label: 'حاليًا داخل', value: s['present']?.toString() ?? '0'),
                _StatCard(label: 'حاليًا خارج', value: s['away']?.toString() ?? '0'),
                _StatCard(label: 'وحدات عليها سجل', value: s['active_units']?.toString() ?? '0'),
                FilledButton.icon(
                  onPressed: c.reload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: rows.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: cs.onSurface.withOpacity(0.12)),
              itemBuilder: (_, i) {
                final r = rows[i];
                final unit = (r['unit_name'] ?? '') as String;
                final pres = (r['is_present'] == 1);
                final lastIn = (r['last_entry'] ?? '') as String;
                final lastOut = (r['last_exit'] ?? '') as String;
                final cars = (r['car_plates'] ?? '') as String;

                return ListTile(
                  leading: Icon(
                    pres ? Icons.home_filled : Icons.home_outlined,
                    color: cs.onSurface,
                  ),
                  title: Text(
                    unit,
                    style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                  subtitle: Text(
                    [
                      pres ? 'داخل' : 'خارج',
                      if (lastIn.isNotEmpty) 'آخر دخول: $lastIn',
                      if (lastOut.isNotEmpty) 'آخر خروج: $lastOut',
                      if (cars.isNotEmpty) 'سيارات: $cars',
                    ].join('  ·  '),
                    style: TextStyle(color: cs.onSurface.withOpacity(0.70)),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 110), // تمنع التضييق الشديد
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: cs.onSurface.withOpacity(0.10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.7))),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
