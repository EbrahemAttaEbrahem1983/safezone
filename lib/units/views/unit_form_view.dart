import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database/sector_dao.dart';
import '../models/unit.dart';

class UnitFormView extends StatefulWidget {
  final Unit? existing;
  final int? preselectedMainId;
  final int? preselectedSubId;
  const UnitFormView({
    super.key,
    this.existing,
    this.preselectedMainId,
    this.preselectedSubId,
  });

  @override
  State<UnitFormView> createState() => _UnitFormViewState();
}

class _UnitFormViewState extends State<UnitFormView> {
  final _formKey = GlobalKey<FormState>();
  final _dao = SectorDao();

  late TextEditingController _name;
  String _status = 'vacant';
  bool _planted = false, _furnished = false, _installments = false;

  int? _mainId;
  int? _subId;
  List<Map<String, Object?>> _mains = [];
  List<Map<String, Object?>> _subs = [];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _status = widget.existing?.status ?? 'vacant';
    _planted = widget.existing?.isPlanted ?? false;
    _furnished = widget.existing?.isFurnished ?? false;
    _installments = widget.existing?.hasInstallments ?? false;
    _load();
  }

  Future<void> _load() async {
    final mains = await _dao.mains();
    _mains = mains.map((e) => e.toMap()).toList();

    _mainId = widget.existing?.mainSectorId ??
        widget.preselectedMainId ??
        (mains.isNotEmpty ? mains.first.id : null);

    await _loadSubs();
  }

  Future<void> _loadSubs() async {
    if (_mainId == null) {
      setState(() => _subs = []);
      return;
    }
    final subs = await _dao.subsByMain(_mainId!);
    setState(() {
      _subs = subs.map((e) => e.toMap()).toList();
      _subId = widget.existing?.subSectorId ??
          widget.preselectedSubId ??
          (subs.isNotEmpty ? subs.first.id : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          title: Text(
            widget.existing == null ? 'إضافة وحدة' : 'تعديل الوحدة',
            style: TextStyle(color: cs.onSurface),
          ),
          iconTheme: IconThemeData(color: cs.onSurface),
          elevation: 0,
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _mainId,
                      isExpanded: true,
                      decoration: _input(context, 'القطاع الرئيسي'),
                      dropdownColor: cs.surfaceVariant,
                      items: _mains
                          .map(
                            (m) => DropdownMenuItem(
                              value: m['id'] as int,
                              child: Text(m['name'] as String,
                                  style: TextStyle(color: cs.onSurface)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _mainId = v);
                        await _loadSubs();
                      },
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _subId,
                      isExpanded: true,
                      decoration: _input(context, 'القطاع الفرعي'),
                      dropdownColor: cs.surfaceVariant,
                      items: _subs
                          .map(
                            (s) => DropdownMenuItem(
                              value: s['id'] as int,
                              child: Text(s['name'] as String,
                                  style: TextStyle(color: cs.onSurface)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _subId = v),
                      validator: (v) => v == null ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _name,
                style: TextStyle(color: cs.onSurface),
                decoration:
                    _input(context, 'اسم الوحدة (يتحول تلقائيًا إلى حروف كبيرة)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: [
                  _chip(cs, 'مزروعة', _planted, (v) => setState(() => _planted = v)),
                  _chip(cs, 'مفروشة', _furnished, (v) => setState(() => _furnished = v)),
                  _chip(cs, 'بها أقساط', _installments, (v) => setState(() => _installments = v)),
                ],
              ),

              const SizedBox(height: 12),

              // الحالة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    isExpanded: true,
                    dropdownColor: cs.surfaceVariant,
                    items: [
                      DropdownMenuItem(
                        value: 'vacant',
                        child: Text('شاغرة', style: TextStyle(color: cs.onSurface)),
                      ),
                      DropdownMenuItem(
                        value: 'occupied',
                        child: Text('مشغولة', style: TextStyle(color: cs.onSurface)),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('صيانة', style: TextStyle(color: cs.onSurface)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'vacant'),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  final unit = Unit(
                    id: widget.existing?.id,
                    name: _name.text.trim().toUpperCase(),
                    mainSectorId: _mainId!,
                    subSectorId: _subId!,
                    isPlanted: _planted,
                    isFurnished: _furnished,
                    hasInstallments: _installments,
                    ownerId: widget.existing?.ownerId,
                    status: _status,
                    notes: widget.existing?.notes,
                  );
                  Navigator.pop(context, unit);
                },
                child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Chip موحّد
  Widget _chip(ColorScheme cs, String label, bool selected, ValueChanged<bool> onSel) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: cs.onSurface)),
      selected: selected,
      onSelected: onSel,
      showCheckmark: false,
      backgroundColor: cs.surfaceVariant,
      selectedColor: cs.primary.withOpacity(0.14), // نفس الفلسفة في الوضعين
      side: BorderSide(color: cs.onSurface.withOpacity(0.08)),
    );
  }

  InputDecoration _input(BuildContext context, String h) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: h,
      hintTextDirection: TextDirection.rtl,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.55)),
      filled: true,
      fillColor: cs.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
