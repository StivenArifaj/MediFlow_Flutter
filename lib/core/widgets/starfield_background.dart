import 'dart:math';
import 'package:flutter/material.dart';

/// Paints the deep-space background: radial gradient + scattered star particles.
/// Use this as the background layer on every screen.
class StarfieldBackground extends StatelessWidget {
  final Widget child;

  const StarfieldBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Radial gradient background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.55),
                radius: 1.35,
                colors: [
                  Color(0xFF0D1F35),
                  Color(0xFF070B12),
                ],
              ),
            ),
          ),
        ),
        // Layer 2: Star particles
        Positioned.fill(
          child: CustomPaint(
            painter: _StarfieldPainter(),
          ),
        ),
        // Layer 3: App content
        child,
      ],
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  // Fixed star positions so they don't flicker on rebuild
  static final List<_Star> _stars = _generateStars();

  static List<_Star> _generateStars() {
    final rng = Random(42); // fixed seed = same stars every time
    return List.generate(18, (_) {
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 0.8 + rng.nextDouble() * 1.4,
        opacity: 0.025 + rng.nextDouble() * 0.055,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in _stars) {
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.radius,
        Paint()..color = Colors.white.withOpacity(star.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Star {
  final double x;
  final double y;
  final double radius;
  final double opacity;

  const _Star({
    required this.x,
    required this.y,
    required this.radius,
    required this.opacity,
  });
}