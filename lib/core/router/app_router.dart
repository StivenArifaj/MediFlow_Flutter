import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/welcome_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/login_screen.dart';
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

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth Stack
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
      path: '/enter-code',
      builder: (context, state) => const EnterCodeScreen(),
    ),
    GoRoute(
      path: '/invite-patient',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return InvitePatientScreen(
          inviteCode: extra?['inviteCode'] ?? '',
          patientName: extra?['patientName'],
        );
      },
    ),

    // Linked Patient Home (separate shell, no bottom nav)
    GoRoute(
      path: '/linked-patient-home',
      builder: (context, state) => const LinkedPatientHome(),
    ),

    // Main Tab Navigator
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainTabScreen(),
      routes: [
        // Medicine routes
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
            final id = medicineId != null ? int.tryParse(medicineId) : null;
            return ReminderSetupScreen(medicineId: id ?? 0);
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

    // Profile routes
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