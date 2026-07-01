import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class InvitePatientScreen extends ConsumerWidget {
  final String inviteCode;
  final String? patientName;

  const InvitePatientScreen({
    super.key,
    required this.inviteCode,
    this.patientName,
  });

  void _shareCode(BuildContext context) {
    final msg =
        'Hi! I\'ve set up MediFlow to manage your medicines. '
        'Download the app and enter this code: $inviteCode to get started. '
        'Download: https://mediflow.app/download';
    SharePlus.instance.share(ShareParams(text: msg));
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Invite Patient'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(color: AppColors.primary),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.caregiverLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.group_add_outlined,
                    color: AppColors.caregiver, size: 36),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 20),

              Text(
                'Your Invite Code',
                style: AppTypography.headlineMedium()
                    .copyWith(color: AppColors.textPrimary),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 8),

              Text(
                patientName != null
                    ? 'Share this code with $patientName. They enter it when they register as a linked patient.'
                    : 'Share this code with the person you care for. They enter it when they register as a linked patient.',
                style: AppTypography.bodyMedium(color: AppColors.textSecondary)
                    .copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 24),

              // Code display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.caregiverLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppColors.caregiver.withValues(alpha: 0.3)),
                ),
                child: Text(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.caregiver,
                    letterSpacing: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.9, 0.9)),

              const SizedBox(height: 20),

              // Share button
              ElevatedButton.icon(
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('Share Code'),
                onPressed: () => _shareCode(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.caregiver,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 10),

              // Copy button
              OutlinedButton.icon(
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('Copy Code'),
                onPressed: () => _copyCode(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.caregiver,
                  side: const BorderSide(color: AppColors.caregiver),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Go to Home →',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
