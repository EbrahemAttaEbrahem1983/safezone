import 'package:get/get.dart';
import 'controllers/dashboard_controller.dart';

class DashboardBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
