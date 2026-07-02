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
