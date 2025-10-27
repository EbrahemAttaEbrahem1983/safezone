// lib/owners/views/tab_enter.dart
import 'package:flutter/material.dart';
import '../database/owners_dao.dart';

class EnterOwnerTab extends StatefulWidget {
  const EnterOwnerTab({super.key});
  @override
  State<EnterOwnerTab> createState() => _EnterOwnerTabState();
}

class _EnterOwnerTabState extends State<EnterOwnerTab> {
  final dao = OwnersDao();
  final _unitCtrl = TextEditingController();
  final _carCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final List<String> _cars = [];
  List<String> _suggest = [];

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
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
      op: 'owner_entry',
      cars: _cars,
      notes: _noteCtrl.text.trim(),
      byWhom: 'الموظف',
    );
    await dao.setPresence(
      unitId: id,
      isPresent: true,
      lastEntry: DateTime.now().toIso8601String(),
      carPlates: _cars,
    );
    _unitCtrl.clear();
    _carCtrl.clear();
    _noteCtrl.clear();
    _cars.clear();
    _snack('تم تسجيل الدخول');
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
                controller: _carCtrl,
                decoration: const InputDecoration(
                  labelText: 'رقم السيارة',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                onSubmitted: (_) {
                  if (_carCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      _cars.add(_carCtrl.text.trim());
                      _carCtrl.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () {
                if (_carCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _cars.add(_carCtrl.text.trim());
                    _carCtrl.clear();
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
          children: _cars
              .map(
                (c) => Chip(
                  label: Text(c),
                  onDeleted: () => setState(() => _cars.remove(c)),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
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
          icon: const Icon(Icons.login),
          label: const Text('حفظ دخول'),
        ),
      ],
    );
  }
}
