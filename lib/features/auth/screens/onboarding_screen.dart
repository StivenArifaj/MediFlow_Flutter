import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.setHasSeenOnboarding(true);
    if (mounted) context.go('/role-selection');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final pages = [
      _OnboardingPage(
        icon: Icons.medication_rounded,
        title: l10n.onboarding_trackMedicines,
        body: l10n.onboarding_trackMedicinesDesc,
      ),
      _OnboardingPage(
        icon: Icons.notifications_active_rounded,
        title: l10n.onboarding_smartReminders,
        body: l10n.onboarding_smartRemindersDesc,
      ),
      _OnboardingPage(
        icon: Icons.favorite_rounded,
        title: l10n.onboarding_monitorHealth,
        body: l10n.onboarding_monitorHealthDesc,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  l10n.common_skip,
                  style: AppTypography.labelLarge(color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) => pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    width: _currentPage == index ? AppDimensions.lg : AppDimensions.sm,
                    height: AppDimensions.sm,
                    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xs),
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.lg,
                0,
                AppDimensions.lg,
                AppDimensions.xxl,
              ),
              child: SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeOnboarding();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                  ),
                  child: Text(
                    _currentPage < pages.length - 1
                        ? l10n.common_next
                        : l10n.onboarding_getStartedCta,
                    style: AppTypography.titleMedium(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.xxl * 2,
            height: AppDimensions.xxl * 2,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [AppDimensions.shadowTeal],
            ),
            child: Icon(
              icon,
              size: 64,
              color: AppColors.textPrimary,
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
          SizedBox(height: AppDimensions.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineLarge(color: AppColors.textPrimary),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
          SizedBox(height: AppDimensions.md),
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge(color: AppColors.textSecondary),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}
