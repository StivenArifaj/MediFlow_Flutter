import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Deep-space radial gradient background with subtle star particles.
/// Wrap any screen's body with this widget.
class StarfieldBackground extends StatelessWidget {
  final Widget child;
  const StarfieldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Radial deep-space gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.spaceBg),
          ),
        ),
        // Starfield dots
        Positioned.fill(
          child: CustomPaint(painter: _StarfieldPainter()),
        ),
        // Content
        child,
      ],
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42); // fixed seed for consistent layout
    final paint = Paint();
    for (int i = 0; i < 40; i++) {
      final x = rand.nextDouble() * size.width;
      final y = rand.nextDouble() * size.height;
      final radius = rand.nextDouble() * 1.2 + 0.3;
      final opacity = rand.nextDouble() * 0.04 + 0.02; // 0.02–0.06
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
