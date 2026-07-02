# Session Log

Append one entry per session, right before /clear. Keep entries short — 
3-5 lines. This is a changelog, not a transcript.

## 2026-07-01 — UI Overhaul v3: floating nav + home rewrite
- main_tab_screen: floating dark pill nav (left:20, right:20, bottom:20, height:68, color #1A2332)
- app_background: radial gradient blobs (primary top-left, caregiver top-right)
- home_screen: header→32px w800 name + notification bell + avatar; progress card→white with % + 3 stat pills; pending card→medication icon + dark "Took It" pill; taken card→clean success card; health tip→purple gradient (#667EEA→#764BA2); FAB→dark circle
- app_theme: ElevatedButton global→#1A2332 dark; OutlinedButton→#E8ECF0 border + textPrimary
- app_colors: softShadow→#1A2332 base (was primary blue)
- flutter analyze: 0 errors

## 2026-07-01 — Premium visual upgrade
- AppColors: softShadow/strongShadow/coloredShadow/gradientCard/card/pill depth system added
- Home progress card: 56px number display + "Complete ✓" pill badge
- Schedule cards: time in pill, StadiumBorder buttons, taken → pill badge, staggered slideX entry
- Health cards: circular icon, 26px bold values, scale animations
- Profile hero: Column → Row (avatar + info side-by-side); all section cards → shadow-based
- Buttons: StadiumBorder globally in AppTheme
- Welcome blobs: solid → RadialGradient; AppBackground stop: 0.5 → 0.55
- 0 errors; next: OpenCode visual re-audit

## 2026-07-01 — UI fixes from audit P0+P1
- Email Confirmation: full light rewrite (StatefulWidget, _isResending)
- Linked Patient Home: _LP class deleted, light theme, AppColors throughout
- History cards: radius standardized to 16px; all loading indicators → AppColors.primary
- Dark mode toggle removed (non-functional); password reset: real Supabase flow
- ponytail comments removed; 0 errors; next: OpenCode re-audit + P2 fixes

## 2026-07-01 — Screen Redesign Pass 5: Reference-image dashboard redesign
- AppColors: pageBackground (0xFFF4F6FA), cardRadius (24.0), chipRadius (50.0), darkButton (0xFF1A1A1A), cardShadow updated to #1A2332 base
- Health: inline title, Health Overview summary card (40px number + "Updated today" pill), metric cards 28px value + column-bottom layout, childAspectRatio 0.95, CustomScrollView with SliverGrid
- History: full dashboard rewrite — period pill tabs (dark selected), 52px adherence number card with fl_chart BarChart (7-day bars), 3 stat boxes (Taken/Streak/Missed), history rows with status icon circle + pill badge
- Profile: SliverAppBar hero kept; _StatsGrid → _StatsRow (3-column: Medicines/Adherence/Streak) shadow card; all section cards 20px margin + shadow-only; Delete button → StadiumBorder
- Add Medicine: circle back button, pageBackground AppBar/Scaffold, section cards shadow-only (24px radius), form type chips → dark pill selected, preset time tiles → dark selected, confirm button → darkButton StadiumBorder 56px
- Medicine Detail: circle back + circle delete buttons, hero card 28px radius with _InfoPill chips row, details/reminders/notes cards shadow-only
- flutter analyze: 0 errors

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

## 2026-07-01 — Visual system upgrade (Warm Medical Premium)
- AppBackground: soft 3-color gradient (F0F7FF → F8FAFB → F5F0FF)
- AppColors: cardShadow, elevatedCardShadow (static finals), gradientCardDecoration, heroCardDecoration, gradientStart/Mid/End added; old ctx-based cardShadow() removed
- Home progress card: blue gradient hero card (2D7DD2 → 1A5BA8) with TweenAnimationBuilder progress bar
- Home header: gradient Container + avatar gradient ring
- Home schedule cards: AppColors.cardShadow, no flat border
- Profile: SliverAppBar expandedHeight:220 with 3-color gradient hero (2D7DD2→1A5BA8→5B6EF5); SingleChildScrollView → CustomScrollView
- Health metric cards: shadows + 48px icon container with border + 24px w800 bold value + colored unit
- Welcome screen: 2 decorative blob circles (opacity 0.08 / 0.06)
- Animations: flutter_animate on home header + progress card + schedule header; spring entry
- 0 errors

## 2026-07-02 — World-class UI overhaul (all screens)
- AppColors rebuilt per new spec: pageBackground F2F4F8, darkButton 141B2D, xs/sm/md/lg shadow scale, card/cardLg/gradientCard/pill helpers; legacy aliases trimmed to only what's referenced
- AppTheme: 56px dark stadium ElevatedButton, transparent centered AppBar, filled 14px inputs
- New CircleButton shared widget (white circle back/action buttons) used in login, register, health detail, reminder setup
- Home progress card → blue gradient hero (52px doses count, white progress bar, Complete ✓ / missed pills)
- Reminder setup screen fully rewritten from leftover neon-dark theme to light design system
- Caregiver dashboard: gradient patient card, shadow cards; linked patient home: stadium buttons, shadow cards
- Profile: in-flow gradient hero card replaces pinned SliverAppBar
- Nav active item → white pill with dark icon/label
- flutter analyze: 0 errors

## 2026-07-02 — Creative polish pass (post-overhaul)
- AppBackground: ambient top gradient fade (primary 0.10 → caregiver 0.04 → transparent, 320px) + DecorCircle shared widget for gradient-card depth
- MainTabScreen wraps tabs in AppBackground; home/health/history/profile scaffolds now transparent so fade shows through
- Home: greeting flipped ("Hello, Name 👋" small / time-greeting 30px big), new _WeekStrip (7 pill days, today = dark pill), decor circles in progress hero + health tip
- Profile hero + caregiver connection card: translucent decor circles inside gradient
- 0 errors

## 2026-07-02 — Linked patient fixes + emergency alert system
- LinkedPatientHome rewritten: modern header (Hello + greeting + date), logout CircleButton w/ confirm dialog, "Cared for by X" pill, amber medication icon circles (no more 💊 emoji), stadium buttons, redesigned empty/all-done states
- EMERGENCY ALERT feature: red "Alert My Caregiver" button pinned as bottomNavigationBar on linked patient home → optional message dialog → inserts into emergency_alerts table
- Caregiver side: MainTabScreen (now stateful) subscribes to Supabase realtime inserts filtered by caregiver_id → full-screen alert dialog (pulsing SOS icon, patient name, message, Acknowledge). Pending unacknowledged alerts also shown on app open + as red shaking banner on caregiver dashboard
- New files: lib/data/services/alert_service.dart, lib/core/widgets/emergency_alert_dialog.dart, supabase/emergency_alerts.sql
- REQUIRED: run supabase/emergency_alerts.sql in Supabase SQL editor (table + RLS + realtime publication) before the feature works
- Health tip card → pastel AI-suggestion style (peach→lavender→blue, sparkle icon, dark text)
- 0 errors
