import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mediflow/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
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

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  String? _submitError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    var valid = true;

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = l10n.auth_emailRequired);
      valid = false;
    } else {
      setState(() => _emailError = null);
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = l10n.auth_passwordRequired);
      valid = false;
    } else {
      setState(() => _passwordError = null);
    }

    if (!valid || _isLoading) return;

    final repo = ref.read(authRepositoryProvider);

    setState(() {
      _isLoading = true;
      _submitError = null;
    });

    try {
      await repo.login(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text,
      );

      if (mounted) context.go('/home');
    } on AuthException catch (_) {
      setState(() {
        _isLoading = false;
        _submitError = l10n.auth_invalidCredentials;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _submitError = l10n.common_error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                      l10n.auth_welcomeBack,
                      style: AppTypography.headlineMedium(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LoginInput(
                      controller: _emailController,
                      label: l10n.auth_email,
                      hint: l10n.auth_email,
                      keyboardType: TextInputType.emailAddress,
                      errorText: _emailError,
                    ),
                    SizedBox(height: AppDimensions.md),
                    _LoginInput(
                      controller: _passwordController,
                      label: l10n.auth_password,
                      hint: l10n.auth_password,
                      obscureText: true,
                      errorText: _passwordError,
                    ),
                    SizedBox(height: AppDimensions.sm),
                    TextButton(
                      onPressed: () {
                        // V2: Contact support - for now no-op
                      },
                      child: Text(
                        l10n.auth_forgotPassword,
                        style: AppTypography.labelLarge(color: AppColors.primary),
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
                                l10n.auth_login,
                                style: AppTypography.titleMedium(
                                    color: AppColors.textPrimary),
                              ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.md),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        l10n.auth_dontHaveAccount,
                        style: AppTypography.labelLarge(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginInput extends StatelessWidget {
  const _LoginInput({
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
