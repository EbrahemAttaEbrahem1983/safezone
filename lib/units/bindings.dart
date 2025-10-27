import 'package:get/get.dart';
import 'database/sector_dao.dart';
import 'database/unit_dao.dart';
import 'controllers/sectors_controller.dart';
import 'controllers/units_controller.dart';

class UnitsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SectorDao());
    Get.lazyPut(() => UnitDao());

    Get.lazyPut(() => SectorsController(Get.find()));
    Get.lazyPut(() => UnitsController(Get.find()));
  }
}
