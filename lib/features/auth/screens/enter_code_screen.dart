import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/firebase_service.dart';
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
      if (!isFirebaseReady) {
        setState(() => _error = 'No internet connection. Firebase is not available.');
        return;
      }

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
      final userId = await repo.register(
        name: result['patientName'] ?? 'Patient',
        email: '${code.toLowerCase()}@linked.mediflow',
        password: 'linked_$code',
        role: 'linked_patient',
      );

      // Register in Firestore
      await registerLinkedPatient(
        patientUid: userId.toString(),
        caregiverUid: result['caregiverUid'],
        inviteCode: code,
        name: result['patientName'] ?? 'Patient',
      );

      if (mounted) context.go('/linked-patient-home');
    } catch (e) {
      setState(() => _error = 'Connection failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go('/role-selection'),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.neonCyan),
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),

                // Title
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('🔗', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: AppDimensions.lg),

                Text(
                  'Enter Your Invite Code',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLarge(color: AppColors.textPrimary),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.sm),

                Text(
                  'Your caregiver shared a 6-character code.\nEnter it below to link your device.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: AppDimensions.xl),

                // 6 OTP-style input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (i) {
                    return Container(
                      width: 48,
                      height: 60,
                      margin: EdgeInsets.only(right: i < 5 ? 8 : 0),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 1,
                        style: AppTypography.headlineLarge(color: AppColors.neonCyan)
                            .copyWith(fontSize: 24, letterSpacing: 0),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                          UpperCaseTextFormatter(),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFF0D1826),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x1A00E5FF)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0x1A00E5FF)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.neonCyan, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall(color: AppColors.error),
                  ),
                ],

                const SizedBox(height: AppDimensions.xl),

                // Connect button
                Container(
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
                      onTap: _isLoading ? null : _connect,
                      borderRadius: BorderRadius.circular(100),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF070B12),
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Connect',
                                style: AppTypography.titleMedium(
                                  color: const Color(0xFF070B12),
                                ).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                const Spacer(),

                Text(
                  'Don\'t have a code? Ask your caregiver to share it from their MediFlow app.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall(color: AppColors.textMuted),
                ),
              ],
            ),
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
