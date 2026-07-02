import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/circle_button.dart';
import '../providers/auth_provider.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      if (_nameController.text.length >= 2) setState(() => _nameError = null);
    });
    _emailController.addListener(() {
      if (AppValidators.isValidEmail(_emailController.text)) setState(() => _emailError = null);
    });
    _passwordController.addListener(() {
      if (_passwordController.text.length >= 6) setState(() => _passwordError = null);
      if (_confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordController.text == _passwordController.text) {
        setState(() => _confirmPasswordError = null);
      }
      setState(() {});
    });
    _confirmPasswordController.addListener(() {
      if (_confirmPasswordController.text == _passwordController.text) {
        setState(() => _confirmPasswordError = null);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _runValidation() {
    bool ok = true;
    setState(() {
      _nameError = null; _emailError = null;
      _passwordError = null; _confirmPasswordError = null; _submitError = null;
    });
    if (_nameController.text.trim().length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      ok = false;
    }
    if (!AppValidators.isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Please enter a valid email');
      ok = false;
    }
    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      ok = false;
    }
    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match');
      ok = false;
    }
    return ok;
  }

  Future<void> _submit() async {
    if (!_runValidation()) return;
    setState(() { _isLoading = true; _submitError = null; });
    try {
      final repo = ref.read(authRepositoryProvider);
      final role = repo.selectedRole ?? 'patient';
      await repo.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        role: role,
      );
      if (!mounted) return;
      final session = supabase.auth.currentSession;
      if (session == null) {
        if (mounted) context.go('/email-confirmation', extra: _emailController.text.trim());
        return;
      }
      if (!mounted) return;
      if (role == 'caregiver') {
        final prefs = await SharedPreferences.getInstance();
        final code = prefs.getString('caregiver_invite_code') ?? '';
        if (mounted) {
          context.pushReplacement('/invite-patient',
              extra: {'inviteCode': code, 'patientName': null});
        }
        return;
      }
      if (role == 'linked_patient') {
        if (mounted) context.go('/linked-patient-home');
        return;
      }
      if (mounted) context.go('/home');
    } catch (e) {
      String msg = 'Something went wrong. Please try again.';
      if (e is sb.AuthException) {
        msg = e.message;
        if (e.statusCode == '429') msg = 'Too many attempts. Please wait a few minutes.';
      } else if (e is Exception) {
        msg = e.toString().replaceAll('Exception: ', '');
      }
      if (mounted) setState(() => _submitError = msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _passwordStrength(String p) {
    if (p.length < 6) return 0;
    final hasUpper = p.contains(RegExp(r'[A-Z]'));
    final hasDigit = p.contains(RegExp(r'[0-9]'));
    final hasSpecial = p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    final score = (hasUpper ? 1 : 0) + (hasDigit ? 1 : 0) + (hasSpecial ? 1 : 0);
    if (score >= 2) return 2;
    if (score >= 1 || p.length >= 8) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(authRepositoryProvider);
    final role = repo.selectedRole ?? 'patient';
    final strength = _passwordStrength(_passwordController.text);

    final (roleLabel, roleColor, roleIcon) = switch (role) {
      'caregiver'     => ('Caregiver', AppColors.caregiver, Icons.people_rounded),
      'linked_patient'=> ('Linked Patient', AppColors.linked, Icons.link_rounded),
      _               => ('Patient', AppColors.primary, Icons.medication_rounded),
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Back + title ─────────────────────────────
                Row(children: [
                  CircleButton(
                    icon: Icons.arrow_back_rounded,
                    size: 40,
                    onTap: () => context.go('/welcome'),
                  ),
                  const SizedBox(width: 16),
                  Text('Create Account', style: AppTypography.h2),
                ]).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Text('Fill in your details to get started',
                      style: AppTypography.bodySmallStyle),
                ).animate().fadeIn(delay: 60.ms, duration: 300.ms),

                const SizedBox(height: 24),

                // ── Role badge ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(roleIcon, color: roleColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Registering as',
                          style: AppTypography.labelSmall),
                      Text(roleLabel,
                          style: AppTypography.label.copyWith(color: roleColor)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // ── Fields ───────────────────────────────────
                _LightField(
                  controller: _nameController, hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name, errorText: _nameError,
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                const SizedBox(height: 12),

                _LightField(
                  controller: _emailController, hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress, errorText: _emailError,
                ).animate().fadeIn(delay: 130.ms, duration: 300.ms),

                const SizedBox(height: 12),

                _LightField(
                  controller: _passwordController, hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword, errorText: _passwordError,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textTertiary, size: 20),
                  ),
                ).animate().fadeIn(delay: 160.ms, duration: 300.ms),

                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PasswordStrengthBar(strength: strength)
                      .animate().fadeIn(duration: 200.ms),
                ],

                const SizedBox(height: 12),

                _LightField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm, errorText: _confirmPasswordError,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textTertiary, size: 20),
                  ),
                ).animate().fadeIn(delay: 190.ms, duration: 300.ms),

                if (_submitError != null) ...[
                  const SizedBox(height: 14),
                  _ErrorBanner(message: _submitError!),
                ],

                const SizedBox(height: 28),

                // ── Create Account button ────────────────────
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.textOnPrimary, strokeWidth: 2))
                      : Text(l10n.auth_createAccount),
                ).animate().fadeIn(delay: 220.ms, duration: 300.ms),

                const SizedBox(height: 16),

                // ── Login link ───────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      style: AppTypography.bodySmallStyle,
                      children: [
                        TextSpan(text: 'Log In',
                          style: AppTypography.label.copyWith(color: AppColors.primary)),
                      ],
                    )),
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 300.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LightField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;

  const _LightField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: AppTypography.body,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20),
        suffixIcon: suffixIcon,
        errorText: errorText,
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0=weak, 1=medium, 2=strong
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.danger, AppColors.warning, AppColors.success];
    final labels = ['Weak', 'Medium', 'Strong'];
    final color = colors[strength];

    return Row(children: [
      ...List.generate(3, (i) => Expanded(
        child: Container(
          height: 4,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(
            color: i <= strength ? color : AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
      const SizedBox(width: 10),
      Text(labels[strength],
          style: AppTypography.labelSmall.copyWith(color: color)),
    ]);
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(message,
            style: AppTypography.bodySmallStyle.copyWith(color: AppColors.danger))),
      ]),
    );
  }
}
