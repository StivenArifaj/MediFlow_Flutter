import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mediflow/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: AppDimensions.xxl * 1.5,
                height: AppDimensions.xxl * 1.5,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [AppColors.cyanGlowStrong],
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeIn(duration: 600.ms),
              const SizedBox(height: AppDimensions.lg),
              Text(
                l10n.appName,
                style: AppTypography.displayMedium(color: AppColors.textPrimary),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: AppDimensions.sm),
              Text(
                l10n.appTagline,
                style:
                    AppTypography.bodyLarge(color: AppColors.textSecondary),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic),
              const SizedBox(height: AppDimensions.xl),
              const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            ],
          ),
      ),
    );
  }
}
