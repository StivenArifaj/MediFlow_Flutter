import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/firebase_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateName() {
    if (_nameController.text.length >= 2) {
      setState(() => _nameError = null);
    }
  }

  void _validateEmail() {
    if (AppValidators.isValidEmail(_emailController.text)) {
      setState(() => _emailError = null);
    }
  }

  void _validatePassword() {
    if (_passwordController.text.length >= 6) {
      setState(() => _passwordError = null);
    }
    if (_confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == _passwordController.text) {
      setState(() => _confirmPasswordError = null);
    }
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text == _passwordController.text) {
      setState(() => _confirmPasswordError = null);
    }
  }

  bool _runValidation() {
    final l10n = AppLocalizations.of(context)!;
    var valid = true;

    if (_nameController.text.trim().length < 2) {
      setState(() => _nameError = l10n.auth_nameRequired);
      valid = false;
    } else {
      setState(() => _nameError = null);
    }

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = l10n.auth_emailRequired);
      valid = false;
    } else if (!AppValidators.isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = l10n.auth_emailInvalid);
      valid = false;
    } else {
      setState(() => _emailError = null);
    }

    if (_passwordController.text.length < 6) {
      setState(() => _passwordError = l10n.auth_passwordMinLength);
      valid = false;
    } else {
      setState(() => _passwordError = null);
    }

    if (_confirmPasswordController.text != _passwordController.text) {
      setState(() => _confirmPasswordError = l10n.auth_passwordMismatch);
      valid = false;
    } else {
      setState(() => _confirmPasswordError = null);
    }

    return valid;
  }

  Future<void> _submit() async {
    if (!_runValidation() || _isLoading) return;

    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(authRepositoryProvider);

    final role = repo.selectedRole ?? 'patient';

    setState(() {
      _isLoading = true;
      _submitError = null;
    });

    try {
      final userId = await repo.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
        role: role,
      );

      // Caregiver: generate invite code and route to invite screen
      if (role == 'caregiver') {
        final prefs = ref.read(sharedPreferencesProvider);
        String inviteCode;
        try {
          inviteCode = await createCaregiverProfile(
            caregiverUid: userId.toString(),
            name: _nameController.text.trim(),
            email: _emailController.text.trim().toLowerCase(),
            patientName: '', // Patient name not yet known
          );
        } catch (_) {
          // Firebase offline — generate local code
          inviteCode = generateInviteCode();
        }
        await prefs.setString('caregiver_invite_code', inviteCode);

        if (mounted) {
          context.go('/invite-patient', extra: {
            'inviteCode': inviteCode,
          });
        }
        return;
      }

      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _submitError = e.message == 'Email already registered'
            ? l10n.auth_emailAlreadyExists
            : e.message;
      });
    } catch (e, stackTrace) {
      debugPrint('Registration error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
        _submitError = '${l10n.common_error}: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.watch(authRepositoryProvider);
    final role = repo.selectedRole ?? 'patient';
    final roleLabel = role == 'caregiver' ? l10n.role_caregiver : l10n.role_patient;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.md,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/welcome'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: AppColors.textPrimary,
                  ),
                  Expanded(
                    child: Text(
                      l10n.auth_createAccount,
                      style: AppTypography.headlineMedium(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AppInput(
                        controller: _nameController,
                        label: l10n.auth_fullName,
                        hint: l10n.auth_fullName,
                        keyboardType: TextInputType.name,
                        errorText: _nameError,
                      ),
                      SizedBox(height: AppDimensions.md),
                      _AppInput(
                        controller: _emailController,
                        label: l10n.auth_email,
                        hint: l10n.auth_email,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _emailError,
                      ),
                      SizedBox(height: AppDimensions.md),
                      _AppInput(
                        controller: _passwordController,
                        label: l10n.auth_password,
                        hint: l10n.auth_password,
                        obscureText: true,
                        errorText: _passwordError,
                      ),
                      if (_passwordController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: AppDimensions.xs),
                          child: _PasswordStrengthBar(password: _passwordController.text),
                        ),
                      SizedBox(height: AppDimensions.md),
                      _AppInput(
                        controller: _confirmPasswordController,
                        label: l10n.auth_confirmPassword,
                        hint: l10n.auth_confirmPassword,
                        obscureText: true,
                        errorText: _confirmPasswordError,
                      ),
                      SizedBox(height: AppDimensions.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              role == 'caregiver' ? Icons.people_rounded : Icons.medication_rounded,
                              color: role == 'caregiver'
                                  ? AppColors.caregiverAccent
                                  : AppColors.primary,
                              size: 24,
                            ),
                            SizedBox(width: AppDimensions.sm),
                            Text(
                              roleLabel,
                              style: AppTypography.bodyMedium(color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                      if (_submitError != null) ...[
                        SizedBox(height: AppDimensions.md),
                        Text(
                          _submitError!,
                          style: AppTypography.bodySmall(color: AppColors.error),
                        ),
                      ],
                      SizedBox(height: AppDimensions.xl),
                      SizedBox(
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  l10n.auth_createAccount,
                                  style: AppTypography.titleMedium(
                                      color: AppColors.textPrimary),
                                ),
                        ),
                      ),
                    ],
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

class _AppInput extends StatelessWidget {
  const _AppInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall(color: AppColors.textSecondary),
        ),
        SizedBox(height: AppDimensions.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: AppTypography.bodyLarge(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.bgInput,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: AppDimensions.xs),
          Text(
            errorText!,
            style: AppTypography.bodySmall(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});

  final String password;

  int _getStrength() {
    var strength = 0;
    if (password.length >= 6) strength++;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength();
    final colors = [
      AppColors.error,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
    ];
    final width = (strength / 4) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 4,
          child: LinearProgressIndicator(
            value: width / 100,
            backgroundColor: AppColors.bgCardLight,
            valueColor: AlwaysStoppedAnimation(colors[strength > 0 ? strength - 1 : 0]),
          ),
        ),
      ],
    );
  }
}
