# MediFlow Flutter — Project State

Last updated: 2026-07-01

## Current Phase
Migrating from Firebase + Drift/SQLite to Supabase (single backend).

## Backend
- Supabase project: xzbxeqhsecicigqmllat
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
- [x] Caregiver registration fixed — auth_repository.dart no longer blocks caregiver role; registers as 'patient' then immediately calls becomeCaregiver() RPC which sets role + generates invite_code atomically. Profile screen invite code display now reads user.inviteCode from Supabase (not SharedPreferences). Catch blocks in register/login screens now handle generic Exception types.

## What's NOT Done Yet
- [ ] CRITICAL: Fix 117 flutter analyze errors — router, screens, and providers still reference old Firebase/Drift/SharedPreferences APIs that no longer exist. App will not compile until this is resolved. This blocks all further feature work.
- [ ] Medicines + Reminders data layer
- [ ] History + Health data layer
- [ ] Caregiver/Linked Patient role logic
- [ ] Notification reschedule fix (rescheduleAll never called)
- [ ] OpenFDA barcode lookup (currently 0% — stub only)
- [ ] Remove dead code: lib/data/database/tables/, unused deps
- [ ] Fix duplicate route registration (caregiver-dashboard)
- [ ] Delete password-bypass security bug in local auth fallback

## Known Bugs From Audit (see 02-BUGS.md for full detail)
- Caregiver dashboard reads own SQLite instead of patient's data
- iOS Firebase broken (missing GoogleService-Info.plist) — moot after migration
- rescheduleAll() never called after login/reinstall
