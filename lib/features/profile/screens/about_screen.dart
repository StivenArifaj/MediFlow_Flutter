import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About MediFlow'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(color: AppColors.primary),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
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
                boxShadow: [AppColors.cyanGlow],
              ),
              child: const Icon(Icons.medication_rounded, size: 48, color: Colors.white),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: AppDimensions.md),

            Text('MediFlow',
                style: AppTypography.headlineLarge()
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Version 1.0.0',
                style: AppTypography.bodyMedium(color: AppColors.primary)),

            const SizedBox(height: AppDimensions.xl),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          width: 3, height: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text('Medical Disclaimer',
                          style: AppTypography.titleMedium(
                              color: AppColors.warning)),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    'MediFlow is a medication organization tool only. It is NOT a medical device and does NOT provide medical advice. Always follow your doctor\'s instructions and consult healthcare professionals for medical decisions. Never change, start, or stop medication based solely on information from this app.',
                    style:
                        AppTypography.bodyMedium(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            const SizedBox(height: AppDimensions.lg),

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
              'Made with care for better health',
              style: AppTypography.bodySmall(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: AppTypography.titleMedium()
                              .copyWith(color: AppColors.textPrimary)),
                      Text(subtitle,
                          style: AppTypography.bodySmall(
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
