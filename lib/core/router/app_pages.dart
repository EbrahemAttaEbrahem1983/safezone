// lib/core/router/app_pages.dart
import 'package:get/get.dart';
import 'package:safe_zone/core/rbac/roles.dart'; // الموحد
import 'package:safe_zone/core/ui/forbidden_view.dart';

import '../../dashboard/dashboard_bindings.dart';
import '../../dashboard/views/dashboard_root.dart';

import '../../units/bindings.dart';
import '../../units/views/units_tabs_root.dart';

// شاشة تمام الملاك
import '../../owners/views/owners_tabs_root.dart';

// Guard & RBAC controller
import '../../auth/rbac_guard.dart';
import '../../auth/rbac_controller.dart';

import 'route_names.dart';

import 'route_names.dart';

// صفحة محظور بسيطة
 

class AppPages {
  AppPages._();

  static const initial = R.root;

  static final pages = <GetPage>[
    GetPage(
      name: R.root,
      page: () => const DashboardRoot(),
      binding: DashboardBindings(),
    ),

    // مثال: حماية صفحة الوحدات (تحتاج Supervisor أو أعلى)
    GetPage(
      name: R.units,
      page: () => const UnitsTabsRoot(),
      binding: UnitsBinding(),
      middlewares: [
        RoleGuard(Role.supervisor), // ستحول المستخدم إلى /forbidden إن لم يكن مصرحًا
      ],
    ),

    GetPage(
      name: R.ownersArrival,
      page: () => const OwnersTabsRoot(),
      // binding: OwnersBinding(), // أضف Binding لو عندك
    ),

    // صفحة محظور (Forbidden)
    GetPage(
      name: R.forbidden,
      page: () => const ForbiddenView(),
    ),
  ];
}
