import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mediflow/l10n/app_localizations.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_background.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ── Logo + branding ──────────────────────────
                Center(
                  child: Column(children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 24, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: const Icon(Icons.medication_rounded,
                          size: 44, color: AppColors.textOnPrimary),
                    ).animate().scale(
                        begin: const Offset(0.9, 0.9),
                        duration: 600.ms,
                        curve: Curves.easeOutCubic).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    Text(l10n.appName, style: AppTypography.display)
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 8),

                    Text(l10n.appTagline,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLargeStyle.copyWith(
                          color: AppColors.textSecondary),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ]),
                ),

                const SizedBox(height: 40),

                // ── Feature pills ────────────────────────────
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _FeaturePill(label: l10n.welcome_featureOcr,
                        icon: Icons.camera_alt_outlined),
                    _FeaturePill(label: l10n.welcome_featureReminders,
                        icon: Icons.alarm_rounded),
                    _FeaturePill(label: l10n.welcome_featureMetrics,
                        icon: Icons.favorite_border_rounded),
                    _FeaturePill(label: l10n.welcome_featurePrivate,
                        icon: Icons.lock_outline_rounded),
                  ],
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                const Spacer(),

                // ── CTA buttons ──────────────────────────────
                ElevatedButton(
                  onPressed: () => context.go('/role-selection'),
                  child: Text(l10n.auth_createAccount),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.auth_alreadyHaveAccount,
                      style: AppTypography.label.copyWith(
                          color: AppColors.primary)),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // ── Disclaimer ───────────────────────────────
                Text(l10n.disclaimer_text,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelSmall.copyWith(fontSize: 12),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final IconData icon;
  const _FeaturePill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary, fontSize: 13)),
      ]),
    );
  }
}
