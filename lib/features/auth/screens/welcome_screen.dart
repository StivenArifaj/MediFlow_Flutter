import 'package:flutter/material.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../../../core/widgets/neon_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: StarfieldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.xl),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [AppColors.cyanGlowStrong],
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.lg),
                Text(
                  l10n.appName,
                  style: AppTypography.displayLarge(color: AppColors.textPrimary)
                      .copyWith(fontSize: 42),
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  l10n.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge(color: AppColors.textSecondary),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.xl),
                Wrap(
                  spacing: AppDimensions.sm,
                  runSpacing: AppDimensions.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _FeatureChip(label: l10n.welcome_featureOcr),
                    _FeatureChip(label: l10n.welcome_featureReminders),
                    _FeatureChip(label: l10n.welcome_featureMetrics),
                    _FeatureChip(label: l10n.welcome_featurePrivate),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.xxl),
                
                NeonButton(
                  label: l10n.auth_createAccount,
                  onPressed: () => context.go('/register'),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                
                const SizedBox(height: AppDimensions.md),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    l10n.auth_alreadyHaveAccount,
                    style: AppTypography.labelLarge(color: AppColors.neonCyan),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.xxl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                  child: Text(
                    l10n.disclaimer_text,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(color: AppColors.textMuted)
                        .copyWith(fontSize: 10),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 700.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: const Color(0x1A00E5FF), width: 1),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall(color: AppColors.textPrimary),
      ),
    );
  }
}
