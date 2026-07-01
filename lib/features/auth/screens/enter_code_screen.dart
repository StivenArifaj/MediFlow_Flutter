import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/providers/shared_preferences_provider.dart';
import '../../../data/services/invite_service.dart';
import '../providers/auth_provider.dart';

class EnterCodeScreen extends ConsumerStatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  ConsumerState<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends ConsumerState<EnterCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _connect() async {
    final code = _code.toUpperCase().trim();
    if (code.length != 6) {
      setState(() => _error = 'Please enter all 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await lookupInviteCode(code);
      if (result == null) {
        setState(() => _error = 'Invalid code. Please check and try again.');
        return;
      }

      // Save linked patient info
      final prefs = ref.read(sharedPreferencesProvider);
      final repo = ref.read(authRepositoryProvider);

      await prefs.setString('linked_caregiver_uid', result['caregiverUid']);
      await prefs.setString('linked_caregiver_name', result['caregiverName'] ?? '');
      await prefs.setString('linked_invite_code', code);
      await prefs.setString('linked_patient_name', result['patientName'] ?? '');
      await repo.setSelectedRole('linked_patient');

      // Create local account
      final email = '${code.toLowerCase()}@linked.mediflow';
      try {
        await repo.register(
          name: result['patientName'] ?? 'Patient',
          email: email,
          password: 'linked_$code',
          role: 'linked_patient',
        );
      } on sb.AuthException catch (_) {
        // User already exists — sign in instead
        await repo.login(email: email, password: 'linked_$code');
      }

      // Register in Firestore (stub — no-op until Supabase invite flow is wired)
      await registerLinkedPatient(
        patientUid: repo.currentUserUid ?? '',
        caregiverUid: result['caregiverUid'],
        inviteCode: code,
        name: result['patientName'] ?? 'Patient',
      );

      if (mounted) context.go('/linked-patient-home');
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Enter Invite Code'),
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
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.linkedLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.link_rounded,
                    color: AppColors.linked, size: 36),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 20),

              Text(
                'Enter Your Code',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium()
                    .copyWith(color: AppColors.textPrimary),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 8),

              Text(
                'Ask your caregiver for their 6-character invite code and enter it below.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(color: AppColors.textSecondary)
                    .copyWith(height: 1.5),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // 6 OTP-style input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  return Container(
                    width: 44,
                    height: 54,
                    margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 1,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.linked,
                          letterSpacing: 0),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp('[a-zA-Z0-9]')),
                        UpperCaseTextFormatter(),
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.linked, width: 2),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && i < 5) {
                          _focusNodes[i + 1].requestFocus();
                        }
                        if (val.isEmpty && i > 0) {
                          _focusNodes[i - 1].requestFocus();
                        }
                        setState(() => _error = null);
                      },
                    ),
                  );
                }),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.danger, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isLoading ? null : _connect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.linked,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Link to Caregiver',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 16),

              Text(
                'Don\'t have a code? Ask your caregiver to share it from their MediFlow app.',
                textAlign: TextAlign.center,
                style:
                    AppTypography.bodySmall(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
