import 'package:get/get.dart';
import 'package:safe_zone/auth/login_view.dart';
import 'package:safe_zone/core/ui/forbidden_view.dart';

import '../../dashboard/dashboard_bindings.dart';
import '../../dashboard/views/dashboard_root.dart';

import '../../units/bindings.dart';
import '../../units/views/units_tabs_root.dart';

import '../../owners/views/owners_tabs_root.dart';

import '../../auth/rbac_guard.dart';
import '../../auth/rbac_controller.dart';
import 'package:safe_zone/core/rbac/roles.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  // ابدأ باللوجين
  static const initial = R.login;

  static final pages = <GetPage>[
    GetPage(
      name: R.login,
      page: () => LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: R.dashboard,
      page: () => const DashboardRoot(),
      binding: DashboardBindings(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: R.units,
      page: () => const UnitsTabsRoot(),
      binding: UnitsBinding(),
      middlewares: [
        RoleGuard(Role.supervisor), // الحد الأدنى للدور
      ],
    ),
    GetPage(
      name: R.ownersArrival,
      page: () => const OwnersTabsRoot(),
    ),
    GetPage(
      name: R.forbidden,
      page: () => const ForbiddenView(),
    ),
  ];
}
