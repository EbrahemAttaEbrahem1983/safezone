import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:safe_zone/auth/rbac_controller.dart';
import 'package:safe_zone/core/rbac/roles.dart';
import 'units/database/app_database.dart';
import 'owners/database/owners_schema.dart';
import 'core/router/app_pages.dart';
import 'core/theme/theme_controller.dart';
import 'core/locale/locale_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ تشغيل Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();
  await UnitsDatabase.instance.init();
  await OwnersSchema.ensure(UnitsDatabase.instance.db);

  // كنترولرات بسيطة (system افتراضيًا)
  Get.put(ThemeController());
  Get.put(LocaleController());
  Get.put(RBACController());

  // للتطوير فقط (اختياري)
  await Get.find<RBACController>().setRole(Role.admin);

  // تأكيد اللغة = لغة الجهاز
  Get.find<LocaleController>().setSystem();

  runApp(const SafeZoneApp());
}

class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  ThemeData _monoTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final base = isLight ? Colors.black : Colors.white;
    final bg   = isLight ? Colors.white : Colors.black;
    final surf = isLight ? const Color(0xFFF2F2F2) : const Color(0xFF1A1A1A);

    final cs = ColorScheme(
      brightness: brightness,
      primary: base, onPrimary: bg,
      secondary: base, onSecondary: bg,
      background: bg, onBackground: base,
      surface: bg, onSurface: base,
      surfaceVariant: surf, onSurfaceVariant: base.withOpacity(0.8),
      error: Colors.red, onError: bg,
      outline: base.withOpacity(0.25),
      shadow: base.withOpacity(0.15),
      inverseSurface: base, onInverseSurface: bg,
      tertiary: base.withOpacity(0.6), onTertiary: bg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      fontFamily: 'NotoNaskhArabic',
      scaffoldBackgroundColor: bg,

      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: base,
        centerTitle: true,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surf,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: base.withOpacity(0.55)),
      ),

    cardTheme: CardThemeData(
  color: surf,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: base.withOpacity(0.06)),
  ),
  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),

      dividerTheme: DividerThemeData(
        color: base.withOpacity(0.12),
        thickness: 0.7,
        space: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: base,
          foregroundColor: bg,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: base,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surf,
        labelStyle: TextStyle(color: base),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: StadiumBorder(side: BorderSide(color: base.withOpacity(0.08))),
      ),

      iconTheme: IconThemeData(color: base),

      textTheme: TextTheme(
        bodyLarge: TextStyle(color: base),
        bodyMedium: TextStyle(color: base),
        bodySmall: TextStyle(color: base.withOpacity(0.8)),
        titleLarge: TextStyle(color: base),
        titleMedium: TextStyle(color: base),
        labelLarge: TextStyle(color: base),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: base,
        unselectedLabelColor: base.withOpacity(0.6),
        indicatorColor: base,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: base,
        foregroundColor: bg,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: surf,
        textStyle: TextStyle(color: base),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeCtrl = Get.find<LocaleController>();
    final themeCtrl  = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: localeCtrl.locale.value, // ← لغة النظام
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: _monoTheme(Brightness.light),
        darkTheme: _monoTheme(Brightness.dark),
        themeMode: themeCtrl.themeMode.value, // ← وضع النظام
        initialRoute: AppPages.initial,
        getPages: AppPages.pages,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
