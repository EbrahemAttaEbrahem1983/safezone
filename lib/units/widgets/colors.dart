// lib/units/widgets/app_colors.dart
import 'package:flutter/material.dart';

/// امتداد على ColorScheme ليحتوي الألوان المستخدمة في الوحدات
/// استخدم Theme.of(context).colorScheme.tileBg مثلاً
extension AppColorScheme on ColorScheme {
  /// لون خلفية البلاطات / الكروت
  Color get tileBg => surfaceVariant;

  /// لون الحشو العالي (مثل خلفية القوائم المنسدلة وحقول الإدخال)
  Color get surfaceHigh => surfaceVariant.withOpacity(0.98);

  /// لون زر الإضافة (FAB) أو الأزرار الأساسية
  Color get fabBg => primary;

  /// خلفية الأزرار الثانوية (أزرار CRUD الخفيفة)
  Color get actionBg => secondaryContainer;

  /// لون نص داخل البلاطات/الأزرار
  Color get tileText => onPrimary;

  /// لون نص ثانوي على السطح (70% opacity)
  Color get onSurface70 => onSurface.withOpacity(0.70);
}

/// واجهة بسيطة للاستعمال في المكان القديم (حافظ على التوافق)
class UnitColors {
  /// نص رئيسي (عالي التباين)
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  /// نص ثانوي على السطح بعتامة 70%
  static Color textOnSurface70(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.70);

  /// خلفية الـ chips وحقول الإدخال
  static Color chipBg(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceHigh;

  /// خلفية البطاقات
  static Color cardBg(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceHigh;
}

/// shim للتوافق مع أي استخدام قديم باسم UnitsColors
class UnitsColors {
  static Color get ok => const Color(0xFF1B5E20);
  static Color get brandGreen => const Color(0xFF1B5E20);
  static Color get bgDark => const Color(0xFF0F2F2A);
  static Color get card => const Color(0xFF18463F);
  static Color get pill => const Color(0xFF18463F);
}
