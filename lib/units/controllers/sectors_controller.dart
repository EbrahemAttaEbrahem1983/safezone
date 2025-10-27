import 'package:get/get.dart';
import '../database/sector_dao.dart';
import '../models/sector.dart';
import 'units_controller.dart';

class SectorsController extends GetxController {
  final SectorDao dao;
  SectorsController(this.dao);

  final mains = <MainSector>[].obs;
  final subs = <SubSector>[].obs;

  // null = الجميع
  final mainId = RxnInt();
  final subId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    // افتح على الجميع/الجميع
    loadMains(selectFirst: false);
  }

  Future<void> loadMains({bool selectFirst = false}) async {
    mains.assignAll(await dao.mains());

    if (mains.isEmpty) {
      mainId.value = null;
      subs.clear();
      subId.value = null;
      return;
    }

    if (selectFirst) {
      mainId.value = mains.first.id;
      await loadSubs(selectFirst: true);
    } else {
      mainId.value = null; // الجميع
      subs.clear();
      subId.value = null;
    }
  }

  Future<void> loadSubs({bool selectFirst = false}) async {
    if (mainId.value == null) {
      subs.clear();
      subId.value = null;
    } else {
      subs.assignAll(await dao.subsByMain(mainId.value!));
      subId.value = selectFirst && subs.isNotEmpty ? subs.first.id : null;
    }

    // مزامنة اختيار الفرعي (اختياري)
    if (Get.isRegistered<UnitsController>()) {
      Get.find<UnitsController>().subId.value = subId.value;
    }
  }

  // CRUD كما هي
  Future<void> addMain(String name) async { await dao.insertMain(name); await loadMains(); }
  Future<void> renameMain(int id, String name) async { await dao.updateMain(id, name); await loadMains(); }
  Future<bool> deleteMain(int id) async { try { await dao.deleteMain(id); await loadMains(); return true; } catch (_) { return false; } }
  Future<void> addSub(int mainId, String name) async { await dao.insertSub(mainId, name); await loadSubs(); }
  Future<void> renameSub(int id, String name) async { await dao.updateSub(id, name); await loadSubs(); }
  Future<bool> deleteSub(int id) async { try { await dao.deleteSub(id); await loadSubs(); return true; } catch (_) { return false; } }

  /// اختيار رئيسي (null = الجميع)
  Future<void> pickMain(int? id) async {
    mainId.value = id;
    await loadSubs(selectFirst: false); // اترك الفرعي = الجميع
  }

  /// اختيار فرعي:
  /// - يضبط subId
  /// - يعيّن تلقائيًا mainId الأب
  /// - يحمّل فرعيات هذا الأب ويحتفظ بالفرعي المختار
  Future<void> pickSub(int? id) async {
    subId.value = id;
    if (id == null) return; // الجميع

    final sub = await dao.getSubById(id);
    if (sub != null && mainId.value != sub.mainId) {
      mainId.value = sub.mainId;
      await loadSubs(selectFirst: false);
      subId.value = id;
    }
  }
}
