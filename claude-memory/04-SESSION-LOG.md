# Session Log

Append one entry per session, right before /clear. Keep entries short — 
3-5 lines. This is a changelog, not a transcript.

## 2026-07-01 — UI Redesign Pass 4 (final)
- health_detail: full light rewrite — surface cards, primary chart, latest value card, light sheet
- scan_screen: neonCyan → scanAccent (0xFF00D4D4) for camera overlay visibility
- invite_patient + enter_code: dark gradient → light AppBar + surface card layout
- splash_screen + about_screen + data_export: cleaned dark references
- neonCyan removed from app_colors; scanAccent added
- UI redesign phase COMPLETE — 0 neon/dark references, 0 analyzer errors
- Next: full OpenCode QA on all screens

## 2026-07-01 — UI Redesign Pass 3: Profile + Caregiver Dashboard
- profile_screen: full visual rewrite — AppBar added, light CircleAvatar, role badge helpers, _StatCell grid (no GlassCard), dedicated invite code card for caregivers, _SettingsTile ListTile pattern, grouped sections with section labels, clean dialogs/sheets
- caregiver_dashboard_screen: AdherenceRing replaced with linear progress + large %, all Color(0xFF0D1826)/0xFF0A1420/0xFF162032 dark hex → AppColors.surface/surfaceVariant, neonCyan → AppColors.caregiver/primary, AppBackground → plain Scaffold, AppBar added
- reminder_setup_screen: GlassCard → Container (so glass_card.dart could be deleted)
- Deleted: neon_button.dart, neon_card.dart, glass_card.dart, starfield_background.dart, adherence_ring.dart
- app_colors.dart: removed neonCardDecoration, glassCardDecoration (truly unused)
- NOTE: neonCyan kept in app_colors — still referenced by health_detail, scan_screen, invite_patient, enter_code screens (not in scope for Pass 3)
- flutter analyze: 0 errors (9 pre-existing warnings/infos)

## 2026-07-01 — UI Redesign Pass 2 (refinement): Home + Navigation polish
- main_tab_screen: already correct (Material3 NavigationBar), no changes needed
- home_screen: progress card redesigned (header "$X of $Y", footer "X remaining"/"On track ✓")
- Avatar tap now routes to /home/profile; schedule header uses TextButton.icon
- Health tip gradient changed to blue→blue (0xFF2D7DD2→0xFF1A5BA8)
- FAB bottom sheet: ListTile → _AddOptionTile with icon containers + chevron
- flutter analyze: 0 errors

## 2026-07-01 — UI Redesign Pass 2: Home + Navigation
- main_tab_screen: replaced custom dark nav row with Material3 NavigationBar (light, blue indicator, border-top separator)
- home_screen: full visual rewrite — light background, linear progress card replaces AdherenceRing, Took It/Skip buttons on pending cards, color-coded left-border for taken/missed/skipped, FAB opens bottom sheet instead of floating mini menu
- Removed: AdherenceRing, GlassCard, _FloatingFab mini-options, _StatsRow, _MedicineCard section, all hardcoded dark hex colors, flutter_animate import, neonCyan refs
- flutter analyze: 0 errors (11 pre-existing warnings)

## 2026-07-01 — QA bug fixes (5 bugs)
- B4 FIXED: Linked patient routing — router redirect checks profiles.role from Supabase on /login and /welcome, routes linked_patient → /linked-patient-home
- B1 NOT FOUND: "100mg by by" — no display code produces this; may be stale test data in Supabase
- B2 FIXED: Save Reminder button moved from GestureDetector in ListView → ElevatedButton in Scaffold.bottomNavigationBar
- B3 FIXED: Caregiver home _loadPatientData() rewritten from SharedPreferences → Supabase profiles query
- B5 FIXED: become_caregiver retry hardened 30×100ms → 10×500ms with explicit profileReady guard
- UX3: add_medicine_screen already had bottomNavigationBar + resizeToAvoidBottomInset default=true — no change needed
- flutter analyze: 0 errors, 16 warnings (all pre-existing)
- Next: UI redesign

## 2026-07-01 — Session 2: Medicines screens migrated to Supabase
- medicines_provider: FutureProvider<List<Map>> watching managedUserIdProvider; medicineByIdProvider and remindersForMedicineProvider added (String ID, not int)
- add_medicine_screen: _submit() rewrites to svc.createMedicine + svc.createReminder + NotificationService.scheduleRemindersForMedicine; Firebase/Drift removed
- medicine_detail_screen: fully rewritten to Map<String,dynamic>; delete cascades reminders then medicine; reminders via remindersForMedicineProvider
- home_screen _MedicineCard updated to Map-based fields; router medicine/:id now passes String
- 0 errors after changes (22 warnings, all pre-existing)
- Next: Session 3 — home screen today's schedule + dose logging

## 2026-07-01 — Session 1: Supabase data service
- Created SupabaseDataService with all CRUD operations (medicines, reminders, history, health measurements, profile stats)
- Created managedUserIdProvider hook — caregiver reads → linked patient's user_id
- Fixed FetchOptions→.count(CountOption.exact) API for supabase_flutter v2
- Zero new compile errors (still 22 warnings, all pre-existing)
- No screens migrated yet — foundation only
- Next: Session 2 (medicines migration)

## 2026-07-01 — Session: Package rename + google-services removal
- Renamed Android package from com.example.mediflow → com.mediflow.app
- Moved MainActivity.kt into com/mediflow/app/ directory, updated package declaration
- Removed google-services Gradle plugin from both android/build.gradle.kts files (Firebase is gone, plugin was blocking build by looking for new package in google-services.json)
- App builds and launches successfully — Supabase init confirmed in logs
- Next: end-to-end auth test (register → email confirmation → login)

## 2026-07-01 — Session: Caregiver registration fix
- FIX 1: Removed hard block in auth_repository.dart for caregiver role; now registers as 'patient' then calls becomeCaregiver() RPC atomically
- FIX 2: register/login catch blocks now handle generic Exception in addition to sb.AuthException; caregiver post-registration now uses unified session-based routing (removed SharedPreferences invite code storage + /invite-patient route)
- FIX 3: Profile screen invite code display switched from SharedPreferences to user.inviteCode from Supabase profiles table
- flutter analyze: 25 warnings (all pre-existing), 0 errors
- Next: End-to-end test — register caregiver, verify invite_code in Supabase dashboard, confirm profile shows code

## 2026-07-01 — Session: Auth fixes + locale + SafeArea
- FIX 1: register/login screens were catching app-defined AuthException (never thrown); replaced with generic catch + `e is sb.AuthException` — Supabase error messages now surface to users
- FIX 2: Register flow now checks currentSession after signUp; routes to /email-confirmation if null (Supabase email verification required), else router redirect handles role-based destination; EmailConfirmationScreen created with resend support
- FIX 3: Default locale changed from 'sq' (Albanian) to 'en' in locale_provider.dart
- FIX 4: Add Medicine confirm button wrapped in SafeArea(top: false); removed MediaQuery.padding.bottom manual calc
- 25 warnings remain (all pre-existing), 0 errors

## 2026-07-01 — Session: Layout black void fix
- Root cause: AppBackground Stack used StackFit.loose by default
- Fix: fit: StackFit.expand — one line, 7 screens corrected
- Tab screens (Home/Health/History/Profile) were not affected — they use Container + gradient pattern which fills correctly
- Pre-existing 117 flutter analyze errors unchanged
- Next: auth exception handling fix (Prompt 1 from previous plan)

## 2026-06-30 — Session: Google Sign-In complete
- google_sign_in package added, minSdk set to 21
- loginWithGoogle()/logout() implemented in AuthRepository
- Google button wired into login_screen.dart
- flutter analyze: 117 pre-existing errors confirmed (router/screens/providers still on old Firebase/Drift APIs) — zero NEW errors introduced by auth work
- Next session MUST be: fix the 117 errors (router redirect logic, screens reading old providers) before any new feature work

## 2026-06-30 — Session: Supabase SDK setup
- Added supabase_flutter ^2.8.0 to pubspec.yaml
- Removed firebase_core, firebase_auth, cloud_firestore
- Created lib/core/supabase/supabase_client.dart
- Next: auth layer migration (replace AuthRepository's Firebase calls)

## [DATE] — Session: Project setup
- Created claude-memory/ folder structure
- Confirmed audit findings, no code changed yet
- Next: Supabase Flutter SDK install + auth layer

## 2026-07-01 — Session 2 verification
- All 7 manual test steps passed on real device
- DNS mismatch found: old anon key had wrong project ref
  baked into JWT. Correct URL is vehkddgphgpjpojralyt
- Always use fresh anon key from Supabase dashboard
- Next: Session 3 (home screen + dose logging)

## 2026-07-01 — Session 6 complete + checkpoint
- Drift removed: 17 files deleted
- OpenFDA barcode: 4-strategy lookup working
- invite_service.dart extracted from firebase_service
- pubspec cleaned of 8 unused packages
- Committed v0.2-backend-complete tag
- Backend phase DONE
- Next: full QA pass then UI redesign

## 2026-07-01 — UI Redesign Pass 1
- Design system replaced: dark neon → light trust
- AppColors: new light palette (primary=0xFF2D7DD2 trust blue), legacy aliases kept for non-auth screens
- AppTypography: added static getter forms alongside legacy method forms (no breakage)
- AppTheme: Material3 light theme, both theme/darkTheme → lightTheme, ThemeMode.light forced
- AppBackground: simple light gradient replacing dark starfield
- 4 auth screens redesigned (welcome, login, register, role_selection)
- 0 errors on flutter analyze
- Next: Pass 2 (Home screen + bottom nav)
