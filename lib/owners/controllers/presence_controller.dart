// lib/owners/controllers/presence_controller.dart
import 'package:get/get.dart';
import '../database/owners_dao.dart';

class PresenceController extends GetxController {
  final dao = OwnersDao();
  final rows = <Map<String, Object?>>[].obs;
  final stats = <String, int>{'present': 0, 'away': 0, 'active_units': 0}.obs;
  final RxBool filterPresent = RxBool(true);

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  Future<void> reload() async {
    stats.assignAll(await dao.presenceStats());
    rows.assignAll(
      await dao.listPresenceRows(isPresent: filterPresent.value ? true : null),
    );
  }
}
