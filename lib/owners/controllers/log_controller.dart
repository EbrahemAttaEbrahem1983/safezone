// lib/owners/controllers/log_controller.dart
import 'package:get/get.dart';
import '../database/owners_dao.dart';

class LogController extends GetxController {
  final dao = OwnersDao();
  final logs = <Map<String, Object?>>[].obs;
  int? unitIdFilter;

  Future<void> loadLedger(int unitId) async {
    unitIdFilter = unitId;
    logs.assignAll(await dao.unitLedger(unitId));
  }
}
