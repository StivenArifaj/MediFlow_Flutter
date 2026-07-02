import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.pageBackground),
        // Soft brand fade from the top — gives every screen a quiet glow
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.10),
                  AppColors.caregiver.withValues(alpha: 0.04),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -80,
          child: _Blob(size: 300, color: AppColors.primary.withValues(alpha: 0.08)),
        ),
        Positioned(
          bottom: -60,
          right: -70,
          child: _Blob(size: 250, color: AppColors.caregiver.withValues(alpha: 0.06)),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

/// Translucent decorative circle for use inside gradient hero cards.
/// Wrap the card content in a ClipRRect + Stack and position a couple
/// of these behind the content for depth (see reference UIs).
class DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const DecorCircle({required this.size, this.opacity = 0.08, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
