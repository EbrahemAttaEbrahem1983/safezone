import 'package:get/get.dart';
import '../database/unit_dao.dart';
import '../models/unit.dart';
import 'sectors_controller.dart';

class UnitsController extends GetxController {
  final UnitDao dao;
  UnitsController(this.dao);

  // القائمة المعروضة
  final items = <UnitWithNames>[].obs;

  // فلاتر (null = الجميع)
  final mainId = RxnInt();
  final subId = RxnInt();
  final _search = ''.obs;
  final _sort = 'newest'.obs;

  // إجماليات
  final total = 0.obs;      // مُفلتر
  final totalAll = 0.obs;   // عام

  // خرائط إحصائية بالمفاتيح الرقمية
  final mainNamesById = <int, String>{}.obs;           // mid -> name
  final perMainById   = <int, int>{}.obs;              // mid -> count
  final perSubsByMid  = <int, Map<String, int>>{}.obs; // mid -> { subName -> count }

  SectorsController get _sectors => Get.find<SectorsController>();
  // ===== CRUD =====
  Future<void> upsert(Unit u) async {
    // تنسيق الاسم وتوحيده قبل الحفظ
    u = u.copyWith(name: u.name.trim().toUpperCase());
    await dao.upsert(u);
    await load(); // حدّث الشاشة بعد الحفظ
  }

  Future<void> remove(int id) async {
    await dao.delete(id);
    await load(); // حدّث الشاشة بعد الحذف
  }

  Future<void> load() async {
    // 1) القائمة حسب الفلاتر
    final rows = await dao.listJoined(
      mainId: mainId.value,
      subId: subId.value,
      search: _search.value.trim(),
      sort: _sort.value,
    );

    items.assignAll(
      rows.map(
        (r) => UnitWithNames(
          unit: Unit(
            id: r['id'] as int?,
            name: r['name'] as String,
            mainSectorId: r['main_id'] as int,
            subSectorId: r['sub_id'] as int,
            isPlanted: (r['is_planted'] as int) == 1,
            isFurnished: (r['is_furnished'] as int) == 1,
            hasInstallments: (r['has_installments'] as int) == 1,
            ownerId: r['owner_id'] as int?,
            status: r['status'] as String,
            notes: r['notes'] as String?,
          ),
          mainName: (r['main_name'] as String?) ?? '',
          subName: (r['sub_name'] as String?) ?? '',
        ),
      ),
    );

    // 2) إجماليات
    total.value    = await dao.countAll(mainId: mainId.value, subId: subId.value, search: _search.value.trim());
    totalAll.value = await dao.countAll();

    // 3) أسماء الرؤوس (من الكنترولر الآخر لضمان الاتساق)
    mainNamesById.assignAll({ for (final m in _sectors.mains) m.id : m.name });

    // 4) الإحصاءات بالرئيسي
    final mRows = await dao.statsPerMainById();
    perMainById.assignAll({
      for (final r in mRows) (r['mid'] as int) : (r['c'] as int)
    });

    // 5) الإحصاءات: الفرعيات داخل كل رئيسي
    final sRows = await dao.statsPerSubByMainById();
    final nested = <int, Map<String,int>>{};
    for (final r in sRows) {
      final mid = r['mid'] as int;
      final sub = (r['sub_name'] as String).trim();
      final c   = r['c'] as int;
      nested.putIfAbsent(mid, () => {});
      nested[mid]![sub] = c;
    }
    perSubsByMid.assignAll(nested);
  }

  // أفعال الفلاتر
  void setMain(int? id) { mainId.value = id; load(); }
  void setSub(int? id)  { subId.value  = id; load(); }
  void setSearch(String q) { _search.value = q; load(); }
  void setSort(String v)   { _sort.value   = v; load(); }
}

class UnitWithNames {
  final Unit unit;
  final String mainName;
  final String subName;
  UnitWithNames({
    required this.unit,
    required this.mainName,
    required this.subName,
  });
}
