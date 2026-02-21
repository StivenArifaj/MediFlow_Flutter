import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';

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
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text('🔗', style: TextStyle(fontSize: 40)),
                  ),
                ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: AppDimensions.lg),

                Text(
                  'Invite Your Patient',
                  style: AppTypography.headlineLarge(color: AppColors.textPrimary),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.sm),

                Text(
                  patientName != null
                      ? 'Share this code with $patientName so they can link their device'
                      : 'Share this code with your patient so they can link their device',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.xl),

                // Code display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1826),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x3300E5FF), width: 2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x3300E5FF), blurRadius: 30),
                    ],
                  ),
                  child: Text(
                    inviteCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonCyan,
                      letterSpacing: 12,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),

                const SizedBox(height: AppDimensions.lg),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0066FF)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          boxShadow: [
                            BoxShadow(color: Color(0x4000E5FF), blurRadius: 20, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _shareCode(context),
                            borderRadius: BorderRadius.circular(100),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.share_rounded, color: Color(0xFF070B12), size: 20),
                                const SizedBox(width: 8),
                                Text('Share Code',
                                    style: AppTypography.titleMedium(color: const Color(0xFF070B12))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1826),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: const Color(0x3300E5FF)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _copyCode(context),
                          borderRadius: BorderRadius.circular(100),
                          child: const Icon(Icons.copy_rounded, color: AppColors.neonCyan, size: 20),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // Skip
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text('Skip for now',
                      style: AppTypography.labelLarge(color: AppColors.textMuted)),
                ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
