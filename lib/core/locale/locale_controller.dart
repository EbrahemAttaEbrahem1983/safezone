// lib/core/locale/locale_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocaleController extends GetxController {
  final locale = (Get.deviceLocale ?? const Locale('ar')).obs;

  void setSystem() {
    locale.value = Get.deviceLocale ?? const Locale('ar');
    update();
  }

  void setArabic() {
    locale.value = const Locale('ar');
    update();
  }

  void setEnglish() {
    locale.value = const Locale('en');
    update();
  }
}
