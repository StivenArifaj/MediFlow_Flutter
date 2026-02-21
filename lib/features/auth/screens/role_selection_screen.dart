import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/auth_provider.dart';

enum UserRole { patient, caregiver, linkedPatient }

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  UserRole? _selectedRole;

  Future<void> _continuePressed() async {
    if (_selectedRole == null) return;

    final repo = ref.read(authRepositoryProvider);

    if (_selectedRole == UserRole.linkedPatient) {
      // Linked patient skips registration → enter code screen
      await repo.setSelectedRole('linked_patient');
      if (mounted) context.go('/enter-code');
      return;
    }

    await repo.setSelectedRole(_selectedRole!.name);
    if (mounted) context.go('/register');
  }

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.xl),
                Text(
                  'Who are you?',
                  style: AppTypography.headlineLarge(color: AppColors.textPrimary),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.sm),
                Text(
                  'Choose how you\'ll use MediFlow',
                  style: AppTypography.bodyLarge(color: AppColors.textSecondary),
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: AppDimensions.xl),

                // Card 1 — Independent Patient
                _RoleCard(
                  icon: Icons.medication_rounded,
                  emoji: '💊',
                  label: 'I manage my own medicines',
                  subtitle: 'Full app for self-management',
                  isSelected: _selectedRole == UserRole.patient,
                  accentColor: AppColors.neonCyan,
                  onTap: () => setState(() => _selectedRole = UserRole.patient),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppDimensions.md),

                // Card 2 — Caregiver
                _RoleCard(
                  icon: Icons.people_rounded,
                  emoji: '🤝',
                  label: 'I manage someone else\'s medicines',
                  subtitle: 'Set up medicines for a family member',
                  isSelected: _selectedRole == UserRole.caregiver,
                  accentColor: AppColors.caregiverAccent,
                  onTap: () => setState(() => _selectedRole = UserRole.caregiver),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppDimensions.md),

                // Card 3 — Linked Patient
                _RoleCard(
                  icon: Icons.link_rounded,
                  emoji: '🔗',
                  label: 'I was invited by a caregiver',
                  subtitle: 'Enter your invite code to get started',
                  isSelected: _selectedRole == UserRole.linkedPatient,
                  accentColor: AppColors.warning,
                  onTap: () => setState(() => _selectedRole = UserRole.linkedPatient),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: AppDimensions.xxl),

                // Continue button
                Container(
                  height: 56,
                  decoration: _selectedRole != null
                      ? const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF0066FF)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                          boxShadow: [
                            BoxShadow(color: Color(0x4000E5FF), blurRadius: 20, offset: Offset(0, 6)),
                          ],
                        )
                      : BoxDecoration(
                          color: AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(100),
                        ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _selectedRole != null ? _continuePressed : null,
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: AppTypography.titleMedium(
                            color: _selectedRole != null
                                ? const Color(0xFF070B12)
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  final IconData icon;
  final String emoji;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1826),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0x1A00E5FF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.2)
                  : const Color(0x1200E5FF),
              blurRadius: isSelected ? 20 : 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.titleMedium(color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.bodySmall(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: accentColor, size: 24),
          ],
        ),
      ),
    );
  }
}
