import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// White circular icon button with a soft shadow — used for back buttons
/// and header actions across the app.
class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? iconColor;
  final Color? background;

  const CircleButton({
    required this.icon,
    this.onTap,
    this.size = 42,
    this.iconColor,
    this.background,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background ?? AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: AppColors.sm,
        ),
        child: Icon(icon, size: size * 0.48,
            color: iconColor ?? AppColors.textPrimary),
      ),
    );
  }
}
