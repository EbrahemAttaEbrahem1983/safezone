class Unit {
  final int? id;
  final String name;
  final int mainSectorId;
  final int subSectorId;
  final bool isPlanted;
  final bool isFurnished;
  final bool hasInstallments;
  final int? ownerId;
  final String status; // 'vacant' | 'occupied' | 'maintenance'
  final String? notes;

  const Unit({
    this.id,
    required this.name,
    required this.mainSectorId,
    required this.subSectorId,
    this.isPlanted = false,
    this.isFurnished = false,
    this.hasInstallments = false,
    this.ownerId,
    this.status = 'vacant',
    this.notes,
  });

  Unit copyWith({
    int? id,
    String? name,
    int? mainSectorId,
    int? subSectorId,
    bool? isPlanted,
    bool? isFurnished,
    bool? hasInstallments,
    int? ownerId,
    String? status,
    String? notes,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      mainSectorId: mainSectorId ?? this.mainSectorId,
      subSectorId: subSectorId ?? this.subSectorId,
      isPlanted: isPlanted ?? this.isPlanted,
      isFurnished: isFurnished ?? this.isFurnished,
      hasInstallments: hasInstallments ?? this.hasInstallments,
      ownerId: ownerId ?? this.ownerId,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'main_id': mainSectorId,
    'sub_id': subSectorId,
    'is_planted': isPlanted ? 1 : 0,
    'is_furnished': isFurnished ? 1 : 0,
    'has_installments': hasInstallments ? 1 : 0,
    'owner_id': ownerId,
    'status': status,
    'notes': notes,
  };

  factory Unit.fromMap(Map<String, Object?> m) => Unit(
    id: m['id'] as int?,
    name: m['name'] as String,
    mainSectorId: m['main_id'] as int,
    subSectorId: m['sub_id'] as int,
    isPlanted: (m['is_planted'] as int? ?? 0) == 1,
    isFurnished: (m['is_furnished'] as int? ?? 0) == 1,
    hasInstallments: (m['has_installments'] as int? ?? 0) == 1,
    ownerId: m['owner_id'] as int?,
    status: (m['status'] as String?) ?? 'vacant',
    notes: m['notes'] as String?,
  );
}
