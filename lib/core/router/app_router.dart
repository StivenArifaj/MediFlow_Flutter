import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

import '../../core/supabase/supabase_client.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/email_confirmation_screen.dart';
import '../../features/auth/screens/enter_code_screen.dart';
import '../../features/auth/screens/invite_patient_screen.dart';
import '../../features/main_tab/main_tab_screen.dart';
import '../../features/linked_patient/screens/linked_patient_home.dart';
import '../../features/medicines/screens/scan_screen.dart';
import '../../features/medicines/screens/add_medicine_screen.dart';
import '../../features/medicines/screens/medicine_detail_screen.dart';
import '../../features/reminders/screens/reminder_setup_screen.dart';
import '../../features/health/screens/health_detail_screen.dart';
import '../../features/profile/screens/caregiver_dashboard_screen.dart';
import '../../features/profile/screens/data_export_screen.dart';
import '../../features/profile/screens/about_screen.dart';

const _publicRoutes = {
  '/welcome',
  '/onboarding',
  '/role-selection',
  '/register',
  '/login',
  '/email-confirmation',
  '/enter-code',
  '/splash',
};

class _SupabaseAuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthChangeEvent> _sub;

  _SupabaseAuthNotifier() {
    _sub = supabase.auth.onAuthStateChange
        .map((e) => e.event)
        .listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _SupabaseAuthNotifier();

final appRouter = GoRouter(
  initialLocation: '/welcome',
  refreshListenable: _authNotifier,
  redirect: (context, state) async {
    final session = supabase.auth.currentSession;
    final loc = state.matchedLocation;

    if (session == null) {
      return _publicRoutes.contains(loc) ? null : '/welcome';
    }

    // Authenticated on a public route — let the screen handle its own
    // post-auth navigation so registration flows (caregiver conversion, etc.)
    // complete before any redirect.
    if (_publicRoutes.contains(loc)) {
      return null;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/email-confirmation',
      builder: (context, state) => EmailConfirmationScreen(
        email: state.extra as String? ?? '',
      ),
    ),
    GoRoute(
      path: '/enter-code',
      builder: (context, state) => const EnterCodeScreen(),
    ),
    GoRoute(
      path: '/invite-patient',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return InvitePatientScreen(
          inviteCode: extra?['inviteCode'] as String? ?? state.uri.queryParameters['code'] ?? '',
          patientName: extra?['patientName'] as String? ?? state.uri.queryParameters['name'],
        );
      },
    ),
    GoRoute(
      path: '/linked-patient-home',
      builder: (context, state) => const LinkedPatientHome(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainTabScreen(),
      routes: [
        GoRoute(
          path: 'scan',
          builder: (context, state) => const ScanScreen(),
        ),
        GoRoute(
          path: 'add-medicine',
          builder: (context, state) {
            final extra = state.extra as Map<String, String?>?;
            return AddMedicineScreen(prefillData: extra);
          },
        ),
        GoRoute(
          path: 'medicine/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            return MedicineDetailScreen(medicineId: id);
          },
        ),
        GoRoute(
          path: 'reminder-setup',
          builder: (context, state) {
            final medicineId = state.uri.queryParameters['medicineId'];
            return ReminderSetupScreen(
                medicineId: int.tryParse(medicineId ?? '') ?? 0);
          },
        ),
        GoRoute(
          path: 'health-detail',
          builder: (context, state) {
            final type = state.uri.queryParameters['type'] ?? 'Weight';
            final unit = state.uri.queryParameters['unit'] ?? '';
            return HealthDetailScreen(type: type, unit: unit);
          },
        ),
        GoRoute(
          path: 'caregiver-dashboard',
          builder: (context, state) => const CaregiverDashboardScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/caregiver-dashboard',
      builder: (context, state) => const CaregiverDashboardScreen(),
    ),
    GoRoute(
      path: '/data-export',
      builder: (context, state) => const DataExportScreen(),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
