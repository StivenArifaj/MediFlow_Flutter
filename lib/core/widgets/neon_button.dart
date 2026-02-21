import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_dimensions.dart';

/// Primary neon gradient button with cyan glow shadow.
class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double height;

  const NeonButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: onPressed != null || isLoading
              ? AppColors.primaryGradient
              : null,
          color: onPressed == null && !isLoading
              ? AppColors.bgCardLight
              : null,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          boxShadow: onPressed != null
              ? const [
                  BoxShadow(
                    color: Color(0x4D00E5FF),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.bgPrimary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.bgPrimary, size: 20),
                      const SizedBox(width: AppDimensions.sm),
                    ],
                    Text(
                      label,
                      style: AppTypography.titleMedium(
                        color: AppColors.bgPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Secondary outlined button with cyan border.
class NeonOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const NeonOutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.neonCyan;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: AppDimensions.buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: c, width: 1.5),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: c, size: 20),
                const SizedBox(width: AppDimensions.sm),
              ],
              Text(label, style: AppTypography.titleMedium(color: c)),
            ],
          ),
        ),
      ),
    );
  }
}
