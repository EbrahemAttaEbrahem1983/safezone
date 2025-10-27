import 'package:flutter/material.dart';

class UnitCard extends StatelessWidget {
  const UnitCard({
    super.key,
    required this.index,
    required this.title,
    required this.mainName,
    required this.subName,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  final int index;
  final String title, mainName, subName, status;
  final VoidCallback onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 6),
            color: cs.onSurface.withOpacity(0.08),
          ),
        ],
        border: Border.all(color: cs.outline.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // أزرار الحذف والتعديل
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: cs.onSurface.withOpacity(0.70),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  color: cs.onSurface.withOpacity(0.70),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(width: 8),

            // المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      _countBadge(context, '${index + 1}'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$mainName • $subName',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.70),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _statusPill(context, status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _countBadge(BuildContext context, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: cs.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static Widget _statusPill(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    final label = switch (status) {
      'occupied' => 'مشغولة',
      'maintenance' => 'صيانة',
      _ => 'شاغرة',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: cs.onPrimary)),
    );
  }
}
