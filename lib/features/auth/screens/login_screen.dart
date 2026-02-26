import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/widgets/starfield_background.dart';
import '../providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';

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
      final user = await repo.getCurrentUser();
      if (user?.role == 'linked_patient') {
        context.go('/linked-patient-home');
      } else {
        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() => _submitError = e.message);
    } catch (_) {
      setState(() => _submitError = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // ── Logo + Title ─────────────────────────────
                Center(
                  child: Column(children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFF0055FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.45),
                              blurRadius: 32, spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.medication_rounded, size: 44, color: Colors.white),
                    ).animate().scale(begin: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeOutBack)
                     .fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    Text(l10n.auth_welcomeBack,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                          color: Colors.white, letterSpacing: -0.5),
                    ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1),

                    const SizedBox(height: 6),

                    const Text('Sign in to continue',
                      style: TextStyle(fontSize: 15, color: Color(0xFF8A9BB5)),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  ]),
                ),

                const SizedBox(height: 40),

                // ── Email ────────────────────────────────────
                _AuthField(
                  controller: _emailController,
                  hint: l10n.auth_email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                  onChanged: (_) { if (_emailError != null) setState(() => _emailError = null); },
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 14),

                // ── Password ─────────────────────────────────
                _AuthField(
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
                      color: const Color(0xFF4A5A72), size: 20),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 10),

                // ── Forgot Password ──────────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please contact support to reset your password.'),
                        backgroundColor: const Color(0xFF0D1826),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    child: Text(l10n.auth_forgotPassword,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF00E5FF),
                          fontWeight: FontWeight.w500)),
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                // ── Submit Error ─────────────────────────────
                if (_submitError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D6A).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF4D6A).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFFF4D6A), size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_submitError!,
                          style: const TextStyle(color: Color(0xFFFF4D6A), fontSize: 13))),
                    ]),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Log In Button ────────────────────────────
                GestureDetector(
                  onTap: _isLoading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null
                          : const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0055FF)]),
                      color: _isLoading ? const Color(0xFF1A2535) : null,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: _isLoading ? [] : [
                        BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.4),
                            blurRadius: 20, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24,
                              child: CircularProgressIndicator(color: Color(0xFF00E5FF), strokeWidth: 2))
                          : Text(l10n.auth_login,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Color(0xFF070B12))),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.08),

                const SizedBox(height: 20),

                // ── Register Link ────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/register'),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: const TextStyle(color: Color(0xFF8A9BB5), fontSize: 14),
                        children: [
                          TextSpan(text: l10n.auth_register,
                            style: const TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Auth Field ────────────────────────────────────────────────────────────────
class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const _AuthField({
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
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1826),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFFF4D6A).withOpacity(0.6)
                  : const Color(0xFF00E5FF).withOpacity(0.12),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF4A5A72), fontSize: 15),
              prefixIcon: Icon(icon, color: const Color(0xFF4A5A72), size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(errorText!,
                style: const TextStyle(color: Color(0xFFFF4D6A), fontSize: 12)),
          ),
        ],
      ],
    );
  }
}