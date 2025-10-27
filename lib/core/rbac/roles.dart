// lib/core/rbac/roles.dart
enum Role {
  individual,
  supervisor,
  superSupervisor,
  manager,
  admin;

  int get level {
    switch (this) {
      case Role.individual:
        return 1;
      case Role.supervisor:
        return 2;
      case Role.superSupervisor:
        return 3;
      case Role.manager:
        return 4;
      case Role.admin:
        return 5;
    }
  }

  /// مفيد لحفظ/قراءة من التخزين كـ String
  String get key => toString().split('.').last;

  /// تحويل من string إلى Role (fallback إلى individual)
  static Role fromKey(String? key) {
    if (key == null) return Role.individual;
    return Role.values.firstWhere(
      (r) => r.key == key,
      orElse: () => Role.individual,
    );
  }
}
