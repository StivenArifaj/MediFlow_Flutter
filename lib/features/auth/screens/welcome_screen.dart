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
        child: Stack(
          children: [
            Positioned(
              top: -80, right: -50,
              child: Container(
                width: 220, height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x262D7DD2), Color(0x002D7DD2)],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 140, left: -70,
              child: Container(
                width: 180, height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1F5B6EF5), Color(0x005B6EF5)],
                  ),
                ),
              ),
            ),
            SafeArea(
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
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 32, offset: const Offset(0, 12)),
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

                OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: Text(l10n.auth_alreadyHaveAccount),
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
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppColors.sm,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall.copyWith(
            color: AppColors.textPrimary, fontSize: 13,
            fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
