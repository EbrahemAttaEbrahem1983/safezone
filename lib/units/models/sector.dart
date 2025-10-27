class MainSector {
  final int id;
  final String name;
  const MainSector({required this.id, required this.name});
  factory MainSector.fromMap(Map<String, Object?> m) =>
      MainSector(id: m['id'] as int, name: m['name'] as String);
  Map<String, Object?> toMap() => {'id': id, 'name': name};
}

class SubSector {
  final int id;
  final int mainId;
  final String name;
  const SubSector({required this.id, required this.mainId, required this.name});
  factory SubSector.fromMap(Map<String, Object?> m) => SubSector(
    id: m['id'] as int,
    mainId: m['main_id'] as int,
    name: m['name'] as String,
  );
  Map<String, Object?> toMap() => {'id': id, 'main_id': mainId, 'name': name};
}
