// lib/owners/views/tab_log.dart
import 'package:flutter/material.dart';
import '../database/owners_dao.dart';

class OwnersLogTab extends StatefulWidget {
  const OwnersLogTab({super.key});
  @override
  State<OwnersLogTab> createState() => _OwnersLogTabState();
}

class _OwnersLogTabState extends State<OwnersLogTab> {
  final dao = OwnersDao();
  List<Map<String, Object?>> _rows = [];
  int _hours = 48;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _rows = await dao.listLogsSince(hours: _hours);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              DropdownButton<int>(
                value: _hours,
                items: const [24, 48, 72, 168]
                    .map(
                      (h) => DropdownMenuItem(
                        value: h,
                        child: Text('آخر $h ساعة'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _hours = v!);
                  _load();
                },
              ),
              const Spacer(),
              FilledButton(onPressed: _load, child: const Text('تحديث')),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _rows.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = _rows[i];
              final unit = (r['unit_name'] ?? '') as String;
              final op = (r['op'] ?? '') as String;
              final at = (r['at'] ?? '') as String;
              final by = (r['by_whom'] ?? '') as String;
              final cars = (r['cars'] ?? '') as String;
              final alerts = (r['alerts'] ?? '') as String;
              final notes = (r['notes'] ?? '') as String;
              return ListTile(
                leading: Icon(
                  op == 'owner_entry'
                      ? Icons.login
                      : (op == 'owner_exit'
                            ? Icons.logout
                            : Icons.verified_user),
                ),
                title: Text('$unit • $op'),
                subtitle: Text(
                  [
                    at,
                    if (by.isNotEmpty) 'بواسطة: $by',
                    if (cars.isNotEmpty) 'سيارات: $cars',
                    if (alerts.isNotEmpty) 'تنبيهات: $alerts',
                    if (notes.isNotEmpty) 'ملاحظة: $notes',
                  ].join('  ·  '),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
