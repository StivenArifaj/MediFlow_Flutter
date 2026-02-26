import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/starfield_background.dart';
import '../providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
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
      setState(() {}); // rebuild for strength bar
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
      if (role == 'caregiver') {
        final user = await repo.getCurrentUser();
        context.pushReplacement('/invite-patient', extra: {
          'inviteCode': user?.firebaseUid ?? '------',
          'patientName': null,
        });
      } else {
        context.go('/home');
      }
    } on AuthException catch (e) {
      setState(() => _submitError = e.message);
    } catch (e) {
      setState(() => _submitError = 'Something went wrong. Please try again.');
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
    final roleLabel = role == 'caregiver' ? 'Caregiver' : 'Patient';
    final roleColor = role == 'caregiver' ? const Color(0xFF8B5CF6) : const Color(0xFF00E5FF);
    final roleIcon = role == 'caregiver' ? Icons.people_rounded : Icons.medication_rounded;
    final strength = _passwordStrength(_passwordController.text);

    return Scaffold(
      backgroundColor: const Color(0xFF070B12),
      body: StarfieldBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // ── Back + Title ────────────────────────────
                Row(children: [
                  GestureDetector(
                    onTap: () => context.go('/welcome'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1826),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF00E5FF), size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Create Account',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                ]).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Text('Fill in your details to get started',
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms),

                const SizedBox(height: 28),

                // ── Role badge ──────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: roleColor.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(roleIcon, color: roleColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Registering as',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
                      Text(roleLabel,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: roleColor)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // ── Full Name ───────────────────────────────
                _RegField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  errorText: _nameError,
                ).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideY(begin: 0.06),

                const SizedBox(height: 12),

                // ── Email ───────────────────────────────────
                _RegField(
                  controller: _emailController,
                  hint: 'Email address',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ).animate().fadeIn(delay: 180.ms, duration: 300.ms).slideY(begin: 0.06),

                const SizedBox(height: 12),

                // ── Password ────────────────────────────────
                _RegField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: const Color(0xFF4A5A72), size: 20),
                  ),
                ).animate().fadeIn(delay: 220.ms, duration: 300.ms).slideY(begin: 0.06),

                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PasswordStrengthBar(strength: strength)
                      .animate().fadeIn(duration: 200.ms),
                ],

                const SizedBox(height: 12),

                // ── Confirm Password ────────────────────────
                _RegField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirm,
                  errorText: _confirmPasswordError,
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    child: Icon(
                      _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      color: const Color(0xFF4A5A72), size: 20),
                  ),
                ).animate().fadeIn(delay: 260.ms, duration: 300.ms).slideY(begin: 0.06),

                // ── Submit error ────────────────────────────
                if (_submitError != null) ...[
                  const SizedBox(height: 14),
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

                // ── Create Account button ───────────────────
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
                              child: CircularProgressIndicator(
                                  color: Color(0xFF00E5FF), strokeWidth: 2))
                          : Text(l10n.auth_createAccount,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                                  color: Color(0xFF070B12))),
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // ── Login link ──────────────────────────────
                GestureDetector(
                  onTap: () => context.go('/login'),
                  child: const Center(
                    child: Text.rich(TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Color(0xFF8A9BB5), fontSize: 14),
                      children: [
                        TextSpan(text: 'Log In',
                          style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w600)),
                      ],
                    )),
                  ),
                ).animate().fadeIn(delay: 340.ms, duration: 300.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reg Field ─────────────────────────────────────────────────────────────────
class _RegField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;

  const _RegField({
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

// ── Password Strength Bar ─────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatelessWidget {
  final int strength; // 0=weak, 1=medium, 2=strong
  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFF4D6A),
      const Color(0xFFFFB800),
      const Color(0xFF00C896),
    ];
    final labels = ['Weak', 'Medium', 'Strong'];
    final color = colors[strength];

    return Row(children: [
      ...List.generate(3, (i) => Expanded(
        child: Container(
          height: 3,
          margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
          decoration: BoxDecoration(
            color: i <= strength ? color : const Color(0xFF1A2535),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      )),
      const SizedBox(width: 10),
      Text(labels[strength],
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}