import 'package:flutter_test/flutter_test.dart';

import 'package:safe_zone/main.dart'; // <-- تطبيقك الحقيقي

void main() {
  testWidgets('يعرض شاشة البداية أو عنوان Safe Zone', (
    WidgetTester tester,
  ) async {
    // ضخّ التطبيق
    await tester.pumpWidget(const SafeZoneApp());

    // لأن SafeZoneApp Stateful وبه AnimatedSwitcher، نعطي فريم لإكمال البناء
    await tester.pumpAndSettle();

    // حاول نلاقي أحد النصّين حسب حالة التخزين المحلي:
    final onboardingTitle = find.text('تسجيل بيانات المستخدم');
    final appTitle = find.text('Safe Zone');

    expect(
      onboardingTitle.evaluate().isNotEmpty || appTitle.evaluate().isNotEmpty,
      true,
    );
  });
}
