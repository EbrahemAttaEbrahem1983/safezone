// lib/auth/rbac_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:safe_zone/core/rbac/roles.dart'; // تأكد هذا المسار

class RBACController extends GetxController {
  static const _kBoxKey = 'rbac_current_role';
  final GetStorage _box = GetStorage();

  final Rx<Role> currentRole = Role.individual.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read<String?>(_kBoxKey);
    currentRole.value = Role.fromKey(saved); // استخدمنا Role.fromKey
  }

  bool allow(Role min) => currentRole.value.level >= min.level;

  Future<void> setRole(Role role) async {
    currentRole.value = role;
    await _box.write(_kBoxKey, role.key);
    update();
  }
}
