// lib/auth/rbac_guard.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safe_zone/core/rbac/roles.dart';
import 'rbac_controller.dart';

class RoleGuard extends GetMiddleware {
  final Role minRole;
  RoleGuard(this.minRole);

  @override
  RouteSettings? redirect(String? route) {
    final rbac = Get.find<RBACController>();
    if (!rbac.allow(minRole)) {
      return const RouteSettings(name: '/forbidden');
    }
    return null;
  }
}
