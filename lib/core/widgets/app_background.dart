import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Theme-aware background — dark mode gets deep navy gradient + stars,
/// light mode gets a clean soft teal-white gradient.
/// Drop-in replacement for StarfieldBackground.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: isDark ? const _DarkBg() : const _LightBg(),
        ),
        child,
      ],
    );
  }
}

class _DarkBg extends StatelessWidget {
  const _DarkBg();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.55),
              radius: 1.6,
              colors: [Color(0xFF0D2040), Color(0xFF05101E)],
            ),
          ),
        ),
        Positioned(
          bottom: -120, left: -80,
          child: Container(
            width: 320, height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x12006880), Color(0x00000000)],
              ),
            ),
          ),
        ),
        const _StarField(),
      ],
    );
  }
}

class _LightBg extends StatelessWidget {
  const _LightBg();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F8FA), Color(0xFFF5FDFE), Color(0xFFEAF7F5)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _StarPainter(), child: const SizedBox.expand());
}

class _StarPainter extends CustomPainter {
  static final _rng = math.Random(42);
  static final _stars = List.generate(55, (_) => (
    x: _rng.nextDouble(),
    y: _rng.nextDouble(),
    r: _rng.nextDouble() * 1.3 + 0.4,
    a: _rng.nextDouble() * 0.04 + 0.02,
  ));

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.r,
        Paint()..color = Colors.white.withValues(alpha: s.a),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

