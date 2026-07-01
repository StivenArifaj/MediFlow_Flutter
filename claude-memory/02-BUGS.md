# Known Bugs (from full audit, pre-migration)

Mark [FIXED] when resolved during migration. Do not re-fix already-fixed items.

13. [FIXED] "Clear All Data" used SQLite DELETEs (dead code post-Supabase migration) and was visually adjacent to Log Out — dangerous naming. Fixed 2026-07-01: renamed to "Delete Account", moved to bottom of Profile as a distinct red OutlinedButton. _deleteAccount() calls deleteMyAccount() RPC (two-step confirmation: warn dialog + must type "DELETE"). Log Out is now purely logout-only, never touches data.
14. [FIXED] linked_patient_home.dart read caregiver name from SharedPreferences ('linked_caregiver_name') — lost on reinstall. Fixed 2026-07-01: _loadData() queries Supabase profiles table for caregiver name, falls back to SharedPreferences.

## QA Bugs — 2026-07-01

B1. [FIXED] "100mg by by" strength display — could not reproduce in current code; display reads `medicine['strength']` directly. May be stale test data. No code change needed.
B2. [FIXED] Save Reminder button not responding — moved from GestureDetector inside ListView to ElevatedButton in Scaffold.bottomNavigationBar (reminder_setup_screen.dart).
B3. [FIXED] Caregiver home reads SharedPreferences — _loadPatientData() in home_screen.dart now queries Supabase profiles table (caregiver_id + invite_code).
B4. [FIXED] Linked patient role routing — router redirect now checks profiles.role from Supabase after login/welcome and routes linked_patient → /linked-patient-home.
B5. [FIXED] become_caregiver race condition — register() in auth_repository.dart now retries 10×500ms (5s total) with explicit profileReady guard before calling RPC.

## Legacy Bugs (pre-migration)

1. [ ] Caregiver dashboard reads own SQLite not patient's Firestore data
2. [ ] Duplicate route: CaregiverDashboardScreen at 2 routes
3. [ ] rescheduleAll() never called — notifications lost on reinstall/restart
4. [ ] lib/data/database/tables/ — dead code, duplicate of app_database.dart
5. [ ] Two competing invite code generators (one weak, one secure)
6. [FIXED] Auth screens caught app-defined AuthException instead of supabase_flutter's AuthException — all error feedback was silently swallowed. Fixed: both screens now use generic catch + `e is sb.AuthException` check with prefix import.
6b. [ ] authStateProvider defined but never consumed by router
7. [ ] users table language default inconsistency (en vs sq in dead code)
8. [ ] Password bypass via stale local SHA-256 hash fallback
9. [ ] printing package installed, never used (pdf export uses share_plus)
10. [ ] iOS Firebase fully broken — moot once migrated to Supabase
11. [FIXED] AppBackground Stack StackFit.loose caused content to shrink to intrinsic height, leaving black void below on tall devices. Fixed with fit: StackFit.expand (one line change in lib/core/widgets/app_background.dart).
12. [FIXED] com.google.gms.google-services plugin remained in android/app/build.gradle.kts and android/build.gradle.kts after Firebase deps were removed — caused processDebugGoogleServices build failure during package rename. Removed from both gradle files.
