import 'package:flutter/material.dart';

class CardCheck extends StatelessWidget {
  final VoidCallback onTap;
  const CardCheck({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            // الخلفية
            Positioned.fill(
              child: Image.asset(
                'assets/images/card_check.png',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay للقراءة
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // العنوان بأسفل يمين مع هامش سفلي واضح
            Positioned(
              right: 14,
              bottom: 12, // ↓ نزّل النص
              child: Text(
                'التشيك',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  shadows: [
                    Shadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.54),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
