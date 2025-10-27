// lib/core/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ThemeChoice { system, light, dark }

class ThemeController extends GetxController {
  final themeMode = ThemeMode.system.obs;
  final choice = ThemeChoice.system.obs;

  void setChoice(ThemeChoice c) {
    choice.value = c;
    switch (c) {
      case ThemeChoice.system:
        themeMode.value = ThemeMode.system;
        break;
      case ThemeChoice.light:
        themeMode.value = ThemeMode.light;
        break;
      case ThemeChoice.dark:
        themeMode.value = ThemeMode.dark;
        break;
    }
    update();
  }
}
