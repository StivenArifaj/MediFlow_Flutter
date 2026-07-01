import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _submitError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    setState(() { _emailError = null; _passwordError = null; _submitError = null; });
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      ok = false;
    }
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      ok = false;
    }
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() { _isLoading = true; _submitError = null; });
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      final role = repo.selectedRole;
      if (role == 'linked_patient') {
        context.go('/linked-patient-home');
      } else {
        context.go('/home');
      }
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

  void _forgotPassword() {
    final emailController =
        TextEditingController(text: _emailController.text.trim());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter your email address and we'll send you a link to reset your password.",
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined,
                    color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);
              try {
                await supabase.auth.resetPasswordForEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Password reset email sent!'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Failed to send reset email'),
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.loginWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ── Header ───────────────────────────────────
                Text(l10n.auth_welcomeBack, style: AppTypography.h1)
                    .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: 6),
                Text('Sign in to continue',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary))
                    .animate().fadeIn(delay: 80.ms, duration: 400.ms),

                const SizedBox(height: 36),

                // ── Email ────────────────────────────────────
                _LightField(
                  controller: _emailController,
                  hint: l10n.auth_email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) { if (_emailError != null) setState(() => _emailError = null); },
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────
                _LightField(
                  controller: _passwordController,
                  hint: l10n.auth_password,
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  onChanged: (_) { if (_passwordError != null) setState(() => _passwordError = null); },
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: AppColors.textTertiary, size: 20),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 10),

                // ── Forgot password ──────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(l10n.auth_forgotPassword,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  ),
                ).animate().fadeIn(delay: 240.ms, duration: 400.ms),

                // ── Submit error ─────────────────────────────
                if (_submitError != null) ...[
                  const SizedBox(height: 12),
                  _ErrorBanner(message: _submitError!),
                ],

                const SizedBox(height: 24),

                // ── Sign In button ───────────────────────────
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: AppColors.textOnPrimary, strokeWidth: 2))
                      : Text(l10n.auth_login),
                ).animate().fadeIn(delay: 280.ms, duration: 400.ms),

                const SizedBox(height: 20),

                // ── Or divider ───────────────────────────────
                Row(children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: AppTypography.labelSmall),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ]),

                const SizedBox(height: 16),

                // ── Google button ────────────────────────────
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: const Icon(Icons.g_mobiledata, size: 26,
                      color: AppColors.textPrimary),
                  label: Text('Continue with Google',
                      style: AppTypography.label.copyWith(
                          color: AppColors.textPrimary)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  ),
                ).animate().fadeIn(delay: 310.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // ── Register link ────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: () => context.go('/register'),
                    child: Text.rich(TextSpan(
                      text: "Don't have an account? ",
                      style: AppTypography.bodySmallStyle,
                      children: [
                        TextSpan(text: l10n.auth_register,
                          style: AppTypography.label.copyWith(color: AppColors.primary)),
                      ],
                    )),
                  ),
                ).animate().fadeIn(delay: 340.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared light text field ────────────────────────────────────────────────────
class _LightField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const _LightField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
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
