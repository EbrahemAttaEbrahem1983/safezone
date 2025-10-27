// lib/ui/dashboard_root.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:safe_zone/owners/views/owners_tabs_root.dart';

/// نسخة محسّنة من DashboardRoot:
/// - نص أبيض ثابت داخل البلاطات
/// - خلفية رأسية متدرجة متحركة
/// - ترتيب وتنسيق محسّن
/// - تأثير دخول متدرج لكل بلاطة (staggered entrance)
/// - تأثير تكبير سريع عند النقر على البلاطة
class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot>
    with SingleTickerProviderStateMixin {
  // الهوية اللونية الثابتة
  static const _bgCream = Color(0xFFF4EFE7);

  // عناصر الشبكة
  static final List<_DashItem> _items = [
    _DashItem(icon: Symbols.apartment, label: 'الوحدات', route: '/units'),
    _DashItem(
      icon: Symbols.groups,
      label: 'الملاك والزوار',
      builder: () => const OwnersTabsRoot(),
    ),
    _DashItem(icon: Symbols.campaign, label: 'بلاغات', route: '/reports'),
    _DashItem(
      icon: Symbols.home_repair_service,
      label: 'العمالة',
      route: '/workforce',
    ),
    _DashItem(icon: Symbols.verified_user, label: 'التفتيش', route: '/check'),
    _DashItem(icon: Symbols.import_export, label: 'تصدير', route: '/export'),
  ];

  // خلفية متدرجة متحركة: نبدل بين مجموعتين من الألوان
  int _bgIndex = 0;
  late Timer _bgTimer;

  // لعمل دخول متدرج (staggered) لكل بلاطة
  late List<bool> _tileVisible;

  @override
  void initState() {
    super.initState();
    _tileVisible = List<bool>.filled(_items.length, false);

    // تفعيل الظهور المتدرج
    for (var i = 0; i < _items.length; i++) {
      Future.delayed(Duration(milliseconds: 120 * i), () {
        if (mounted) setState(() => _tileVisible[i] = true);
      });
    }

    // تبديل خلفية الرأس كل 6 ثواني
    _bgTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(() => _bgIndex = (_bgIndex + 1) % 3);
    });
  }

  @override
  void dispose() {
    _bgTimer.cancel();
    super.dispose();
  }

  LinearGradient _currentHeaderGradient(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // ثلاث حالات متدرجة يمكن تخصيصها
    switch (_bgIndex) {
      case 1:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            cs.primary.withOpacity(0.8),
            cs.primary.withOpacity(0.45),
            Colors.transparent,
          ],
        );
      case 2:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.teal.shade700.withOpacity(0.82),
            Colors.teal.shade400.withOpacity(0.38),
            Colors.transparent,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            cs.onSurface.withOpacity(0.45),
            cs.onSurface.withOpacity(0.18),
            Colors.transparent,
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bgCream,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: SizedBox(
                    height: 190,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/header_banner.png',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),

                        // Overlay متدرج متحرك
                        Positioned.fill(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              gradient: _currentHeaderGradient(context),
                            ),
                          ),
                        ),

                        // نص ظلّي - ابيض
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: _ShadowText(
                            'نراقب . نجرد . نحلل . قرار افضل',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // شبكة البلاطات
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final cross = w >= 1200
                          ? 5
                          : w >= 900
                              ? 4
                              : w >= 650
                                  ? 3
                                  : 2;
                      final rows = (_items.length / cross).ceil();
                      const spacing = 14.0;
                      final gridH = c.maxHeight;
                      final tileH = (gridH - spacing * (rows - 1)) / rows;

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cross,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          mainAxisExtent: tileH,
                        ),
                        itemBuilder: (ctx, i) {
                          final it = _items[i];

                          // تغليف لتأثير الدخول المتدرج + تأثير التكبير عند النقر
                          return AnimatedOpacity(
                            duration: const Duration(milliseconds: 420),
                            opacity: _tileVisible[i] ? 1 : 0,
                            curve: Curves.easeOut,
                            child: AnimatedPadding(
                              duration: const Duration(milliseconds: 420),
                              padding: EdgeInsets.only(
                                  top: _tileVisible[i] ? 0 : 10),
                              child: _ActionTile(
                                icon: it.icon,
                                label: it.label,
                                onTap: () {
                                  if (it.builder != null) {
                                    Get.to(it.builder!);
                                  } else {
                                    Get.toNamed(it.route);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShadowText extends StatelessWidget {
  final String data;
  final TextStyle style;
  const _ShadowText(this.data, {required this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      textAlign: TextAlign.center,
      style: style.copyWith(
        shadows: [
          Shadow(
            blurRadius: 6,
            color: Colors.black.withOpacity(0.42),
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  // خلفية بلاطة مرنة: يمكن بسهولة تغييرها هنا
  static Color _tileBackground() => const Color(0xFF3F5F50);

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  static const double _iconSize = 52;
  static const double _fill = 1.0;
  static const double _weight = 650;
  static const double _grade = 100;
  static const double _optical = 48;

  // حالة التكبير القصير عند الضغط
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          Feedback.forTap(context);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: _ActionTile._tileBackground(),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: _iconSize,
                  color: Colors.white, // نص + ايقونات بيضاء كما طلبت
                  fill: _fill,
                  weight: _weight,
                  grade: _grade,
                  opticalSize: _optical,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashItem {
  final IconData icon;
  final String label;
  final String route;
  final Widget Function()? builder;
  const _DashItem({
    required this.icon,
    required this.label,
    this.route = '',
    this.builder,
  });
}
