class Inspection {
  final String id;
  final String unitId;
  final DateTime date;
  final String inspector;
  final String status;
  final String? notes;
  final int updatedAt;
  final String updatedBy;
  final bool isDeleted;
  Inspection({
    required this.id,
    required this.unitId,
    required this.date,
    required this.inspector,
    required this.status,
    this.notes,
    required this.updatedAt,
    required this.updatedBy,
    this.isDeleted = false,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'unit_id': unitId,
    'date': date.millisecondsSinceEpoch,
    'inspector': inspector,
    'status': status,
    'notes': notes,
    'updated_at': updatedAt,
    'updated_by': updatedBy,
    'is_deleted': isDeleted ? 1 : 0,
  };
}
