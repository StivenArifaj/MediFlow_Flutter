import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_background.dart';
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
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),

                Text('Who are you?', style: AppTypography.h1)
                    .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 6),
                Text("Choose how you'll use MediFlow",
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary))
                    .animate().fadeIn(delay: 80.ms, duration: 400.ms),

                const SizedBox(height: 32),

                _RoleCard(
                  icon: Icons.medication_rounded,
                  label: 'I manage my own medicines',
                  subtitle: 'Full app for self-management',
                  isSelected: _selectedRole == UserRole.patient,
                  accentColor: AppColors.primary,
                  onTap: () => setState(() => _selectedRole = UserRole.patient),
                ).animate().fadeIn(delay: 160.ms, duration: 400.ms),

                const SizedBox(height: 12),

                _RoleCard(
                  icon: Icons.people_rounded,
                  label: "I manage someone else's medicines",
                  subtitle: 'Set up medicines for a family member',
                  isSelected: _selectedRole == UserRole.caregiver,
                  accentColor: AppColors.caregiver,
                  onTap: () => setState(() => _selectedRole = UserRole.caregiver),
                ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                const SizedBox(height: 12),

                _RoleCard(
                  icon: Icons.link_rounded,
                  label: 'I was invited by a caregiver',
                  subtitle: 'Enter your invite code to get started',
                  isSelected: _selectedRole == UserRole.linkedPatient,
                  accentColor: AppColors.linked,
                  onTap: () => setState(() => _selectedRole = UserRole.linkedPatient),
                ).animate().fadeIn(delay: 320.ms, duration: 400.ms),

                const Spacer(),

                ElevatedButton(
                  onPressed: _selectedRole != null ? _continuePressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole != null
                        ? AppColors.darkButton
                        : AppColors.surfaceVariant,
                    foregroundColor: _selectedRole != null
                        ? Colors.white
                        : AppColors.textTertiary,
                  ),
                  child: const Text('Continue'),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.alphaBlend(
                  accentColor.withValues(alpha: 0.04), AppColors.surface)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border(
            left: BorderSide(
                color: isSelected ? accentColor : Colors.transparent, width: 4),
          ),
          boxShadow: AppColors.md,
        ),
        child: Row(children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textSecondary)),
            ]),
          ),
          isSelected
              ? Icon(Icons.check_circle_rounded, color: accentColor, size: 24)
              : Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                ),
        ]),
      ),
    );
  }
}
