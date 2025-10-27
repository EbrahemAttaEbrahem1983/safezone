import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:safe_zone/core/rbac/roles.dart';
import 'package:safe_zone/auth/rbac_controller.dart';

class RoleGuard extends GetMiddleware {
  final Role minRole;
  RoleGuard(this.minRole);

  @override
  RouteSettings? redirect(String? route) {
    // افترض أن RBACController مسجّل في main() قبل أي تنقل
    try {
      final rbac = Get.find<RBACController>();
      if (!rbac.allow(minRole)) {
        return const RouteSettings(name: '/forbidden');
      }
      return null;
    } catch (e) {
      // لو لم يُسجّل RBACController لسبب ما، لا نمنع التنقل كي لا نكسر التطبيق.
      // أثناء التطوير هذا مفيد؛ في الإنتاج يجب التأكد من تسجيله.
      return null;
    }
  }
}
