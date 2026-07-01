# MediFlow Flutter — Project State

Last updated: 2026-07-01 (Session 5 — Profile, caregiver dashboard, export, linked patient home migrated)

## Current Phase
Migrating from Firebase + Drift/SQLite to Supabase (single backend).

## Backend
- Supabase URL: https://vehkddgphgpjpojralyt.supabase.co
- Anon key: get from Supabase dashboard Settings → API
- CRITICAL: The old anon key in previous prompts was wrong
  (pointed to old Lovable project). Always get fresh key
  from dashboard before running the app.
- Shared with the web version of MediFlow (same database, same RLS policies)
- Auth: Supabase Auth (email + password, Google Sign-In to be added)
- Email verification: required
- Password minimum: 8 characters

## Architecture Decisions (do not re-litigate these)
- 3 roles: patient, caregiver, linked_patient — permanent at registration, never changeable
- Caregiver data routing uses managedUserId pattern: caregiver writes go to 
  linked patient's user_id, never their own
- RLS is the only real authorization layer — client-side role checks are UI 
  convenience only, never trusted for security
- flutter_secure_storage for session tokens (Keychain/Keystore), not 
  SharedPreferences
- Account deletion must cascade through all 5 tables + remove the Auth user

## What's Done
- [x] SESSION 2: Medicines migration verified on real device
  (Moto G05) — add/view/delete all working against Supabase
- supabase_flutter ^2.8.0 added, firebase_core/firebase_auth/cloud_firestore removed, lib/core/supabase/supabase_client.dart created
- Auth layer migration — AuthRepository, auth_provider, current_user_provider rewritten for Supabase
- Google Sign-In wired (web + android OAuth clients created, loginWithGoogle() implemented, button added to login screen)
- [x] Layout black void fixed — AppBackground Stack changed from StackFit.loose to StackFit.expand. All 7 affected screens now fill the full screen correctly on all device heights.
- [x] Auth exception handling fixed — both register/login screens now catch Supabase's AuthException via `sb.AuthException` prefix; rate-limit (429) shows user-friendly message.
- [x] Email confirmation interstitial added — /email-confirmation route + EmailConfirmationScreen; register flow checks currentSession after signUp and routes accordingly.
- [x] Default locale changed from Albanian ('sq') to English ('en'); user-chosen locale from Profile still overrides.
- [x] Add Medicine confirm button wrapped in SafeArea(top: false) — no longer hidden behind system nav bar.
- [x] Package renamed: com.example.mediflow → com.mediflow.app (MainActivity.kt + build.gradle.kts namespace + applicationId + folder structure)
- [x] Firebase completely removed — last artifact was com.google.gms.google-services plugin in both gradle files; removed during package rename. google-services.json no longer referenced anywhere.
- [x] Supabase data service created (lib/data/services/supabase_data_service.dart)
- [x] managedUserId hook created (lib/core/hooks/managed_user_id.dart)
- [x] Foundation ready for screen migrations
- [x] SESSION 2: Medicines screens migrated to Supabase
  - medicines_provider.dart: FutureProvider<List<Map>> replacing Drift StreamProvider<List<Medicine>>
  - add_medicine_screen.dart: save logic on Supabase, local notifications scheduled after reminder creation
  - medicine_detail_screen.dart: reads/deletes via Supabase providers (Map-based, String IDs)
  - home_screen _MedicineCard updated to Map fields; router medicine/:id passes String UUID
- [x] Caregiver registration fixed — auth_repository.dart no longer blocks caregiver role; registers as 'patient' then immediately calls becomeCaregiver() RPC which sets role + generates invite_code atomically. Profile screen invite code display now reads user.inviteCode from Supabase (not SharedPreferences). Catch blocks in register/login screens now handle generic Exception types.

- [x] SESSION 3: Home screen migrated to Supabase
  - todayScheduleProvider (lib/features/home/today_schedule_provider.dart) builds schedule from Supabase reminders + history
  - doseLoggerProvider handles Take/Skip/late logic, invalidates provider on success
  - Adherence ring connected to today's real data (taken/skipped/missed from todayScheduleProvider)
  - rescheduleAll() now called on every SIGNED_IN event in _SupabaseAuthNotifier (Bug #4 fixed)
  - rescheduleAll signature changed from Drift List<Reminder> to List<Map<String,dynamic>>
  - home_screen.dart: all Drift + Firebase imports removed

- [x] SESSION 4: Health + History screens migrated to Supabase
  - health_providers.dart: latestMeasurementsProvider, measurementsForTypeProvider, MeasurementNotifier
  - history_provider.dart: historyProvider with medicines joined
  - health_screen.dart: reads latestMeasurementsProvider, _MetricSheet uses MeasurementNotifier
  - health_detail_screen.dart: reactive via measurementsForTypeProvider, add/delete via notifier
  - history_screen.dart: historyProvider, medicine name from joined data, taken_late counted

- [x] SESSION 5: Profile stats, caregiver dashboard, data export, linked patient home migrated
  - profile_providers.dart: profileStatsProvider (real stats), linkedPatientProvider, caregiverPatientDataProvider
  - profile_screen.dart: Drift removed, stats grid live from Supabase, regenerate/unlink/export all Supabase
  - caregiver_dashboard_screen.dart: Bug #1 FIXED — now reads patient's Supabase data via caregiverPatientDataProvider + todayScheduleProvider
  - data_export_screen.dart: Drift removed, JSON + PDF export via Supabase
  - linked_patient_home.dart: Firebase stubs removed, now uses todayScheduleProvider + doseLoggerProvider
  - pdf_export_service.dart: Rewritten to accept List<Map<String,dynamic>> (no Drift types)

- [x] SESSION 6: Drift completely removed, OpenFDA wired
  - reminder_setup_screen migrated to Supabase (int→String medicineId, Drift DAO → createReminder)
  - missed_dose_service.dart deleted (dead code, replaced by todayScheduleProvider)
  - firebase_service.dart split: lookupInviteCode/registerLinkedPatient/unlinkPatient → invite_service.dart, rest deleted
  - lib/data/database/ entire directory deleted (Drift DAOs, tables, generated files)
  - Removed from pubspec: drift, sqlite3_flutter_libs, path, lottie, flutter_secure_storage, printing, purchases_flutter, riverpod_annotation, drift_dev, build_runner, riverpod_generator
  - OpenFDA barcode lookup implemented (openfda_service.dart)
  - Barcode scan → OpenFDA lookup → add_medicine prefill wired
  - Banner shown in add_medicine_screen when data from barcode scan

## What's NOT Done Yet
- [ ] Fix duplicate route registration (caregiver-dashboard)
- [ ] Delete password-bypass security bug in local auth fallback

## Known Bugs From Audit (see 02-BUGS.md for full detail)
- [FIXED] Bug #1: Caregiver dashboard reads own SQLite instead of patient's data
- iOS Firebase broken (missing GoogleService-Info.plist) — moot after migration
- [FIXED] rescheduleAll() never called after login/reinstall
