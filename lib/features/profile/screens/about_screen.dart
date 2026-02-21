import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.8),
            radius: 1.5,
            colors: [Color(0xFF0D1F35), Color(0xFF070B12)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.neonCyan),
                    ),
                    Text('About MediFlow', style: AppTypography.headlineMedium()),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: AppDimensions.lg),

                      // Logo
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [AppColors.cyanGlowStrong],
                        ),
                        child: const Icon(Icons.medication_rounded, size: 48, color: Colors.white),
                      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

                      const SizedBox(height: AppDimensions.md),

                      Text('MediFlow', style: AppTypography.headlineLarge()),
                      const SizedBox(height: 4),
                      Text('Version 1.0.0',
                          style: AppTypography.bodyMedium(color: AppColors.neonCyan)),

                      const SizedBox(height: AppDimensions.xl),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1826),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(width: 3, height: 18, color: AppColors.warning),
                                const SizedBox(width: 8),
                                Text('Medical Disclaimer',
                                    style: AppTypography.titleMedium(color: AppColors.warning)),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.sm),
                            Text(
                              'MediFlow is a medication organization tool only. It is NOT a medical device and does NOT provide medical advice. Always follow your doctor\'s instructions and consult healthcare professionals for medical decisions. Never change, start, or stop medication based solely on information from this app.',
                              style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                      const SizedBox(height: AppDimensions.lg),

                      // Links
                      _LinkTile(
                        icon: Icons.email_rounded,
                        label: 'Contact Support',
                        subtitle: 'support@mediflow.app',
                        onTap: () {},
                      ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                      _LinkTile(
                        icon: Icons.privacy_tip_rounded,
                        label: 'Privacy Policy',
                        subtitle: 'mediflow.app/privacy',
                        onTap: () {},
                      ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                      _LinkTile(
                        icon: Icons.description_rounded,
                        label: 'Terms of Service',
                        subtitle: 'mediflow.app/terms',
                        onTap: () {},
                      ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                      _LinkTile(
                        icon: Icons.star_rounded,
                        label: 'Rate MediFlow',
                        subtitle: 'Leave a review on the app store',
                        onTap: () {},
                      ).animate().fadeIn(delay: 350.ms, duration: 300.ms),

                      const SizedBox(height: AppDimensions.xxl),

                      Text(
                        'Made with 💙 for better health',
                        style: AppTypography.bodySmall(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1826),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x1A00E5FF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2035),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.neonCyan, size: 18),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppTypography.titleMedium()),
                      Text(subtitle, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
