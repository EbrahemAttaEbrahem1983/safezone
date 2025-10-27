// lib/owners/views/tab_exit.dart
import 'package:flutter/material.dart';
import '../database/owners_dao.dart';

class ExitOwnerTab extends StatefulWidget {
  const ExitOwnerTab({super.key});
  @override
  State<ExitOwnerTab> createState() => _ExitOwnerTabState();
}

class _ExitOwnerTabState extends State<ExitOwnerTab> {
  final dao = OwnersDao();
  final _unitCtrl = TextEditingController();
  final _alertCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final List<String> _alerts = [];
  List<String> _suggest = [];
  bool _closedAlerts = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _suggest = await dao.unitNames();
    setState(() {});
  }

  Future<void> _save() async {
    final upper = _unitCtrl.text.trim().toUpperCase();
    if (upper.isEmpty) return;
    final id = await dao.unitIdByUpperName(upper);
    if (id == null) {
      _snack('الوحدة غير موجودة');
      return;
    }
    await dao.addLog(
      unitId: id,
      op: 'owner_exit',
      alerts: _alerts,
      notes: _noteCtrl.text.trim(),
      byWhom: _closedAlerts ? 'السيستم (إغلاق التنبيهات)' : 'الموظف',
    );
    await dao.setPresence(
      unitId: id,
      isPresent: false,
      lastExit: DateTime.now().toIso8601String(),
    );
    _unitCtrl.clear();
    _alertCtrl.clear();
    _noteCtrl.clear();
    _alerts.clear();
    _closedAlerts = true;
    setState(() {});
    _snack('تم تسجيل الخروج');
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Autocomplete<String>(
          optionsBuilder: (t) {
            final q = t.text.trim().toUpperCase();
            if (q.isEmpty) return const Iterable<String>.empty();
            return _suggest.where((s) => s.toUpperCase().contains(q));
          },
          onSelected: (v) => _unitCtrl.text = v,
          fieldViewBuilder: (ctx, ctrl, focus, onSubmit) {
            _unitCtrl.value = ctrl.value;
            return TextField(
              controller: ctrl,
              focusNode: focus,
              decoration: const InputDecoration(
                labelText: 'رقم الوحدة',
                prefixIcon: Icon(Icons.home),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _alertCtrl,
                decoration: const InputDecoration(
                  labelText: 'تنبيه/ملاحظة (باب، ماء، غاز...)',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                onSubmitted: (_) {
                  if (_alertCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _alerts.add(_alertCtrl.text.trim());
                      _alertCtrl.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                if (_alertCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _alerts.add(_alertCtrl.text.trim());
                    _alertCtrl.clear();
                  });
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة'),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: _alerts
              .map(
                (a) => Chip(
                  label: Text(a),
                  onDeleted: () => setState(() => _alerts.remove(a)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          value: _closedAlerts,
          onChanged: (v) => setState(() => _closedAlerts = v),
          title: const Text('تم التشبيك فورًا (إغلاق بند التنبيهات)'),
        ),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'ملاحظات',
            prefixIcon: Icon(Icons.note_alt),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.logout),
          label: const Text('حفظ خروج'),
        ),
      ],
    );
  }
}
