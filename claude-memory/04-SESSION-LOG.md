# Session Log

Append one entry per session, right before /clear. Keep entries short — 
3-5 lines. This is a changelog, not a transcript.

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
