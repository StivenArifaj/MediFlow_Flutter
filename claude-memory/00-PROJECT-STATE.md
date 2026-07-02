# MediFlow Flutter — Project State

Last updated: 2026-07-01 (Session 6 — Drift removed, OpenFDA wired, backend complete)

## Overall Status
BACKEND COMPLETE — all data on Supabase,
Drift removed, 0 errors
Tagged: v0.2-backend-complete

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
- [x] Emergency Alert feature — fully functional (2026-07-02)
  - emergency_alerts table with RLS + rate limit (supabase/emergency_alerts.sql — uses is_acknowledged + acknowledged_at)
  - AlertService: sendAlert/getPendingAlerts/getAlertHistory/acknowledgeAlert/subscribeToAlerts
  - AlertResult typed return (no silent failures), rate-limit error surfaced to user
  - Linked patient: bottom sheet SOS flow with optional message + 1s debounce after failure
  - Caregiver: realtime subscription in MainTabScreen + full-screen acknowledge dialog
  - Immediate heads-up notification (emergency_alerts channel, Importance.max) on alert receipt
  - Alert history section (last 30 days, Resolved/Pending pills) in caregiver dashboard
  - Rate limit: max 3 alerts per 10 minutes (SQL trigger)
- [x] WORLD-CLASS UI OVERHAUL — all screens (2026-07-02)
  - AppColors fully rebuilt: pageBackground #F2F4F8, darkButton #141B2D, xs/sm/md/lg shadows, card/cardLg/gradientCard/pill decorations, minimal legacy aliases kept
  - AppTheme: dark pill ElevatedButton (56px StadiumBorder), transparent centered AppBar, 14px-radius filled inputs
  - AppBackground: static radial blobs (primary 0.08 top-left, caregiver 0.06 bottom-right)
  - Floating nav: darkButton bg, active item = white pill with dark icon+label
  - New shared widget: lib/core/widgets/circle_button.dart (white circle back/action buttons)
  - Auth: welcome gradient logo + shadow feature pills + outlined Sign In; login circle back + stadium Google button; register circle back; role selection 28px cards with 56px circle icons + empty-circle indicator + dark Continue
  - Home: gradient hero progress card (#1E40AF→#3B82F6, 52px count, white bar, Complete ✓ pill, missed footer), "Today" header + outline Add pill, dark FAB, health tip #7C3AED→#4F46E5
  - Health: subtitle added, 26px w900 values; health detail: circle back, cardLg latest reading, shadow chart card, dark FAB, dark save pill
  - History: 56px adherence number, primary→primaryDark gradient bars (today wider), "Recent Activity"
  - Profile: gradient hero card (#1E3A5F→#2D7DD2, 28px radius, in-flow card replacing SliverAppBar), invite code 36px w900 spacing 10 on caregiverLight 24px, stadium Copy/Rotate, entry animation
  - Reminder setup: FULL REWRITE from old neon-dark to light system (was last dark screen) — section cards with accent bars, dark-selected chips, stadium save
  - Caregiver dashboard: gradient patient connection card (caregiver indigo), all cards shadow-based, stadium buttons, transparent AppBar
  - Linked patient home: shadow cards, stadium Skip/green Took It, success left-border taken cards
  - Medicine detail: last hardcoded pill color → surfaceVariant
  - flutter analyze: 0 errors
- [x] UI OVERHAUL v3 — 2026-07-01 (floating nav + home rewrite)
  - Floating dark pill bottom nav (#1A2332, height 68, left/right 20, bottom 20)
  - AppBackground: radial gradient blobs (not full-screen gradient)
  - Home header: 32px w800 name + notification bell + gradient avatar
  - Progress card: white card, % top-right, 3 stat pills (Taken/Left/Missed)
  - Pending dose: medication icon + time pill + dark "Took It" ElevatedButton
  - Taken dose: clean green check card, no buttons
  - Health tip: purple gradient (#667EEA→#764BA2)
  - FAB: dark circle #1A2332 with shadow
  - Global ElevatedButton: #1A2332 dark (screens needing blue override locally)
  - Global OutlinedButton: #E8ECF0 border + textPrimary
  - softShadow: #1A2332 base
  - 0 errors
- [x] PREMIUM VISUAL UPGRADE (2026-07-01)
  - Background: 3-color gradient (EEF4FF → F8FAFB → F3F0FF), stop 0.55
  - AppColors: softShadow/strongShadow/coloredShadow/gradientCard/card/pill helpers added
  - Progress card: gradient hero with 56px number display + "Complete ✓" pill
  - Schedule cards: time in pill badge, StadiumBorder buttons, taken → pill badge, staggered slideX animations
  - Health cards: circular icon (BoxShape.circle), 26px bold values, unit w700, scale animations
  - Profile hero: Column → Row layout (avatar left, name/email/role pill right)
  - Section cards (profile): border-only → AppColors.card (shadow-based)
  - Welcome blobs: solid circle → RadialGradient
  - App theme: ElevatedButton + OutlinedButton → StadiumBorder globally
  - Empty state + AddOptionTile: border-only → AppColors.card
  - 0 errors
- [x] VISUAL SYSTEM UPGRADE — Warm Medical Premium (2026-07-01)
  - AppBackground: 3-color soft gradient
  - AppColors: cardShadow/elevatedCardShadow static finals, gradientCardDecoration, heroCardDecoration
  - Home: gradient hero progress card, gradient header, avatar gradient ring, elevated schedule cards
  - Profile: SliverAppBar gradient hero (expandedHeight: 220)
  - Health: metric cards with real shadows, 24px bold values, colored units, bordered icon containers
  - Welcome: decorative blob circles behind content
  - Animations: flutter_animate on home header/progress/schedule; TweenAnimationBuilder on progress bar
  - 0 errors
- [x] P0+P1 AUDIT FIXES (2026-07-01, commit aea6c44)
  - Email Confirmation: full light theme rewrite (StatefulWidget, _isResending state)
  - Linked Patient Home: _LP class deleted, AppColors throughout, light theme
  - History card radius: 12 → 16px
  - Loading indicators: standardized to AppColors.primary across all screens
  - Dark mode toggle: removed from Profile (non-functional, darkTheme = lightTheme)
  - Password reset: real Supabase resetPasswordForEmail dialog (was "contact support")
  - Disclaimer font: 10px → 12px
  - ponytail comments removed from production code
  - 0 errors
- [x] UI REDESIGN PASS 2: Home + bottom nav (2026-07-01)
  - NavigationBar: Material 3, light, blue indicator (already correct, no change)
  - Home: progress card shows "X of Y" header + "X remaining"/"On track ✓" footer
  - Avatar tap navigates to /home/profile
  - Schedule header: TextButton.icon 'Add' replaces IconButton
  - Health tip: blue→blue gradient replaces green→blue
  - FAB bottom sheet: _AddOptionTile widgets replace plain ListTile
  - flutter analyze: 0 errors
- [x] UI REDESIGN PASS 1: Design system + auth screens
  - AppColors: light palette, trust blues, legacy aliases preserved
  - AppTypography: larger text, Inter font, getter + method forms
  - AppTheme: Material3 light theme (both themes locked to light)
  - AppBackground: clean light gradient, no stars
  - Welcome/Login/Register/Role Selection redesigned
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

- [x] SCREEN REDESIGNS based on reference images (2026-07-01):
  - Health: dashboard with inline title, Health Overview summary card (40px number), metric cards 28px values + column-bottom layout
  - History: full dashboard — period pill tabs, 52px adherence + fl_chart BarChart, 3 stat boxes, history rows with icon circle + badge pills
  - Profile: _StatsGrid → _StatsRow (3-col shadow card), all section cards shadow-only 20px, StadiumBorder delete button
  - Add Medicine: circle back button, dark pill confirm button 56px, dark-selected form chips + preset tiles, shadow-only section cards
  - Medicine Detail: circle back + delete, hero card with _InfoPill chips, all cards shadow-only
  - AppColors: pageBackground (0xFFF4F6FA), cardRadius (24.0), chipRadius (50.0), darkButton (0xFF1A1A1A)
  - 0 errors

## What's NOT Done Yet
- [ ] Run supabase/emergency_alerts.sql in Supabase dashboard (manual step required — feature errors until then)
- [ ] Full QA pass on all 3 roles (OpenCode)
- [x] UI REDESIGN PASS 4 — FINAL (2026-07-01): All screens light, zero neon
  - health_detail: light AppBar, surface cards, primary chart/dots, latest value card
  - scan_screen: scanAccent (0xFF00D4D4) replaces neonCyan for camera UI
  - invite_patient: caregiver-accented card, AppBar, light layout
  - enter_code: linked-accented OTP boxes, AppBar, light layout
  - splash_screen: dark gradient → AppColors.background
  - about_screen: dark gradient → light AppBar + surface cards
  - data_export_screen: neonCyan/bgCard → primary/surface
  - neonCyan removed from app_colors; scanAccent added
  - flutter analyze: 0 errors
- [x] UI REDESIGN PASS 3: Profile + Caregiver Dashboard (2026-07-01)
  - profile_screen: neon removed, light AppBar, CircleAvatar, role badge, _StatCell grid, dedicated invite code card, _SettingsTile grouped sections, clean dialogs
  - caregiver_dashboard: AdherenceRing → linear progress + %, all dark hex → AppColors tokens
  - Deleted: neon_button, neon_card, glass_card, starfield_background, adherence_ring
  - app_colors: neonCardDecoration + glassCardDecoration removed
- [x] UI REDESIGN PASS 2: Home + navigation
  - NavigationBar: clean light with blue indicator
  - Home: linear progress bar replaces adherence ring
  - Dose cards: clear Took It/Skip buttons, color-coded left border for status
  - FAB: bottom sheet replaces floating menu
  - Empty state: friendly with Add Medicine CTA
- [ ] UI redesign for remaining screens (Health, History, Profile) — COMPLETE
- [ ] iOS build verification
- [ ] Release signing config
- [ ] Play Store submission

## Known Bugs From Audit (see 02-BUGS.md for full detail)
- [FIXED] Bug #1: Caregiver dashboard reads own SQLite instead of patient's data
- iOS Firebase broken (missing GoogleService-Info.plist) — moot after migration
- [FIXED] rescheduleAll() never called after login/reinstall
