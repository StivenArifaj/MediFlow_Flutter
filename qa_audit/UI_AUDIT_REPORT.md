# MediFlow UI Audit Report

**Date:** July 1, 2026
**Device:** sdk gphone64 arm64 (Android 14 API 34 emulator)
**App version:** v0.2 post-redesign
**Auditor:** OpenCode QA Agent
**Build:** Debug APK built successfully (Flutter 3.44.4, Dart 3.12.2)

---

## Executive Summary

MediFlow v0.2 represents a major visual step forward from its dark/neon/gaming past. The new light palette (`#F8FAFB` backgrounds, white cards, `#2D7DD2` primary blue) is consistent, clean, and medically appropriate. The onboarding and auth flows are polished with smooth `flutter_animate` transitions, proper form validation, and role-specific accent colors. However, several legacy dark-theme screens remain un-migrated (Email Confirmation, Linked Patient home) that clash severely with the light aesthetic. The overall UX is functional and complete but lacks the final 10% of polish — inconsistent divider patterns, stale `ponytail` code paths, and raw emoji usage instead of vector icons.

**Biggest strength:** Cohesive new light color system applied across 80% of screens with consistent card styling (border, radius, shadow) and good typography via Google Fonts Inter.

**Biggest weakness:** Two completely different visual languages coexist ("clean medical light" vs "dark neon gaming") — the Email Confirmation and Linked Patient screens are dark-themed remnants that break the user's trust in the visual identity.

---

## Overall Score: 6.5/10

---

## Screen-by-Screen Analysis

### 01. Splash Screen
**Screenshot:** screenshots/01_splash.png
**Layout:** Centered column. Circular gradient container (primaryGradient: `#2D7DD2` → `#1A5BA8`) with medication icon. App name and tagline below. `CircularProgressIndicator` at bottom for loading.
**Issues found:**
- The splash is purely visual — no app initialization logic visible in the splash itself (it redirects immediately to `/welcome`)
- `CircularProgressIndicator` uses default blue rather than `AppColors.primary` — minor inconsistency
- No branded splash behind the scenes — just a plain scaffold background color
**Polish score:** 7/10

### 02. Welcome Screen
**Screenshot:** screenshots/02_welcome.png
**Layout:** `AppBackground` gradient (`primaryLight` → `background`), top-centered logo circle (80px, primary blue with glow shadow), "MediFlow" in display style (32px Inter Bold), tagline in secondary text. 4 feature pills in a centered Wrap. CTA button + "Already have an account?" link + medical disclaimer at bottom 10px font.
**Issues found:**
- **Logo uses emoji `medication_rounded` icon** — fine for MVP but generic
- Feature pills are small (14px icons, 13px text) — readable but could be more prominent
- Disclaimer text at 10px — borderline illegible, though legally necessary
- Bottom half uses `Spacer()` — content is top-heavy. ~40% screen used, bottom 60% is just the button + link
- "Already have an account?" styled as `label` (14px semibold primary) — text style name doesn't match semantic use
- No app version or build number shown
**Polish score:** 7/10

### 03. Role Selection Screen
**Screenshot:** screenshots/03_role_selection_default.png, screenshots/03_role_selection_patient_selected.png
**Layout:** 3 vertical role cards: Patient (blue), Caregiver (indigo `#5B6EF5`), Linked Patient (amber `#F5A623`). Each card has a 4px left accent border, icon container (48px square), title + subtitle, and optional checkmark on selection. Cards animate in with staggered delays. "Continue" button at bottom.
**Issues found:**
- **Selected state is subtle** — background tint is only 6% opacity, might not be obvious to 65+ users
- All 3 cards are NOT fully visible on smaller screens without scrolling when combined with the title/subtitle at top and the Continue button at bottom. On 6.1" screens the 3rd card is partially clipped
- No "back" button to go to Welcome
- Continue button disabled state uses `surfaceVariant` background with `textTertiary` text — low contrast, barely visible
- Selected card shows checkmark but no border-weight change on top/right/bottom borders
**Polish score:** 7.5/10

### 04. Register Screen
**Screenshot:** screenshots/04_register_empty.png, screenshots/04_register_filled.png, screenshots/04_register_error.png
**Layout:** Back button + "Create Account" title, role badge (colored left-border based on role), 4 form fields (Full Name, Email, Password, Confirm Password), password strength bar, error banner, submit button, login link.
**Issues found:**
- **Password strength bar** only appears after typing starts — good behavior
- Strength bar shows 3 segments (danger/warning/success) with labels "Weak/Medium/Strong" — excellent
- Error banner uses `dangerLight` background with red text + error icon — well styled
- **Role badge only shows left border** — the card itself doesn't have a full border on top/right/bottom, which looks inconsistent with other cards
- Form fields use `_LightField` from login — consistent, but the label sits above the field (good)
- No international phone field for SMS notifications
- "Registering as" badge has 52px height — good tap target
**Polish score:** 8/10

### 05. Login Screen
**Screenshot:** screenshots/05_login.png, screenshots/05_login_filled.png
**Layout:** "Welcome back" h1, subtitle, email field with mail icon, password field with lock icon + visibility toggle, "Forgot password?" link right-aligned, sign-in button with loading spinner, "or" divider + Google button, register link at bottom.
**Issues found:**
- **Forgot password currently shows a SnackBar saying "contact support"** — not a real password reset flow. This is a functional gap, not a visual issue
- Google sign-in button uses `Icons.g_mobiledata` — this is the old "G" icon, not the official Google branding
- Loading spinner on sign-in button is 22px with 2px stroke — good, doesn't distort button
- The `_LightField` component is duplicated between login and register screens (same code in both files) — violates DRY
- Divider uses `Divider` widget with `AppColors.border` — consistent
**Polish score:** 7.5/10

### 06. Home Tab (Empty State)
**Screenshot:** screenshots/06_home_empty.png
**Layout:** Greeting header ("Good Morning/Afternoon" + name + date), avatar CircleAvatar with initials, empty state card with medication icon (56px, tertiary color), "No medicines yet" h3 text, description, "Add Medicine" button (160x48, primary), health tip NOT shown when no meds exist.
**Issues found:**
- **Empty state is well-designed** — icon, title, description, CTA. One of the best empty states in the app
- Progress card is hidden when `total == 0` — correct behavior
- FAB is always visible even when empty — could be the primary add CTA
- Bottom nav has 4 tabs with `NavigationBar` (M3) — correctly styled with `alwaysShow` labels
- Avatar radius 24px, font size 18px — good proportions
**Polish score:** 8/10

### 07. FAB Bottom Sheet
**Screenshot:** screenshots/07_fab_bottom_sheet.png
**Layout:** Modal bottom sheet with drag handle (40x4 rounded), "Add Medicine" title, "Choose how to add" subtitle, 2 option tiles — "Scan Medicine Box" (primary blue icon) and "Add Manually" (success green icon).
**Issues found:**
- **Bottom sheet radius is 24px** on top corners — consistent with other sheets
- Handle is `AppColors.border` — matches system convention
- Option tiles use `_AddOptionTile` with 52px icon containers, 16px padding, chevron right
- **No backdrop blur** — the sheet overlays a `Colors.transparent` scaffold background
- Good use of distinct icon colors for visual differentiation
**Polish score:** 8/10

### 08. Add Medicine Form
**Screenshot:** screenshots/08_add_medicine_top.png, screenshots/08_add_medicine_form_chips.png, screenshots/08_add_medicine_reminder.png
**Layout:** Full scrollable form with section cards: Basic Information, Medicine Details (form type chips + quantity + expiry), Notes & Memos, Set Reminder (4 time presets, frequency, duration, additional options). Sticky bottom "Confirm & Add Medicine" button in `bottomNavigationBar`.
**Issues found:**
- **Form is comprehensive** — possibly too long. Users must scroll through 4 sections
- Form type chips are `ChoiceChip` 10 options — wraps properly, selected = primaryLight bg + primary border
- Reminder time presets (Morning 08:00, Afternoon 14:00, Evening 20:00, Bedtime 22:00) are clear with emoji + label + time
- **Frequency section uses Material `Radio`** — not styled as themed radio buttons, uses default platform style
- "Specific days" uses custom `GestureDetector` containers instead of Material `Chip` — inconsistent with form type chips
- Snooze duration picks (5/10/15/30 min) use custom container chips — again inconsistent
- Step labels ("Step 1: Choose Time", "Step 2: Frequency") are good UX
- Section cards have colored left-border accents (primary, success, warning, caregiver) — excellent visual hierarchy
**Polish score:** 7.5/10

### 09. Home Tab (With Medicine)
**Screenshot:** screenshots/09_home_with_medicine.png
**Layout:** Same header + avatar, progress card ("Today's Progress" with `taken/total`, LinearProgressIndicator, "X remaining" + "On track ✓"), "Today's Schedule" section header with "Add" TextButton, schedule cards with pill emoji, name, time, Skip/Took It buttons.
**Issues found:**
- **Progress card uses `success` green for progress bar** — good, reinforces positive behavior
- "On track ✓" shown when `missed == 0` — nice touch
- Schedule cards have proper pending state: pill emoji + name (16px bold), time (14px secondary), snooze icon, Skip (outlined) and "✓ Took It" (success green filled) buttons
- **Cancel/skip buttons use `ElevatedButton` and `OutlinedButton`** from theme — consistent
- Health tip appears below schedule with blue gradient card
**Polish score:** 8/10

### 10. After Taking Dose
**Screenshot:** screenshots/10_after_took_it.png
**Layout:** Schedule card changes to "taken" state — green left border, green checkmark icon + "Taken" text, no action buttons. Progress updates to "X of X doses taken", bar fills green.
**Issues found:**
- SnackBar shows "✅ [medicine] marked as taken" with green background — good feedback
- Card switches from `_PendingCard` to the status-based `_ScheduleCard` — different widget entirely, which means animation isn't smooth (it's a hard swap)
- **No undo option** — once "Taken" is pressed, there's no way to revert
- Progress card updates via provider invalidation — reactive, good
**Polish score:** 8/10

### 11. Health Tab
**Screenshot:** screenshots/11_health_grid.png, screenshots/11_health_scrolled.png
**Layout:** AppBar "Health", 2-column GridView with 13 metric cards (Weight, Blood Pressure, Heart Rate, Blood Glucose, Temperature, SpO2, Steps, Sleep, Water Intake, BMI, Cholesterol, Waist, Respiratory Rate). Each card has colored icon circle, value (or "—" for empty), unit, metric name.
**Issues found:**
- **2-column grid with `childAspectRatio: 1.1`** — cards are slightly taller than wide, readable
- 13 metrics is comprehensive — scrolls naturally
- Each metric has unique color — good visual distinction
- "—" for empty values is clear
- **Bottom sheet for logging** uses Cupertino-style pickers with gradient fade overlays — well done
- Weight bottom sheet includes dual drum-roll (kg + decimal) — excellent UX for precise entry
- Blood Pressure uses dual field (systolic/diastolic) — appropriate
- **BMI uses `numberPad` input** — not calculated from height/weight, which is a functional gap
- Scrolls behind bottom nav? Need to verify. GridView with `padding: 16` should account for bottom
**Polish score:** 8.5/10

### 12. History Tab
**Screenshot:** screenshots/12_history.png, screenshots/12_history_filter_7days.png
**Layout:** AppBar "History", adherence summary card (large % number + period label + 3 stat boxes for Taken/Skipped/Missed + streak fire pill), filter chips (Today/7 Days/30 Days/All Time) + status chips (All/Taken/Skipped/Missed), history entry cards.
**Issues found:**
- **Adherence % is 48px bold, color-coded** (green ≥80%, amber ≥50%, red <50%) — excellent
- Streak uses fire emoji "🔥" — could be a custom vector icon instead
- Filter chips are `FilterChip` widgets — properly styled, selected = primaryLight with primary border
- History entries have left-border color-coded status (green=taken, grey=skipped, amber=missed)
- **Badge pill** uses `_StatusBadge` with 20px border radius — clean
- Empty state uses raw emoji "💊" at 52px — fine but could be `medication_outlined` icon
- **"7 Days" filter** changes label to "Last 7 days" in the adherence card — nice touch
**Polish score:** 8/10

### 13. Profile Tab
**Screenshot:** screenshots/13_profile_top.png, screenshots/13_profile_scrolled.png
**Layout:** Avatar section (CircleAvatar 44px radius + edit button overlay), name + email, role badge (colored chip). Stats grid (6 cells: Medicines, Health Logs, Days Active, Missed Doses, Streak, Member Since). Preferences section (Language, Dark Mode, Notifications with switches). Data section (Export, Cloud Backup "Premium" badge, About). Account section (My Role, Log Out, Delete Account red-outlined).
**Issues found:**
- **Stats grid uses a 2x3 Container** — clean but cell values are hardcoded to the same font size regardless of number length
- Dark mode toggle exists but is non-functional — `darkTheme = lightTheme`, meaning toggling does nothing visually
- "Premium" badge on Cloud Backup is a subtle upsell — well integrated
- **Delete Account button is visually dangerous** — red-outlined with proper spacing from Log Out
- Settings tiles use `_SettingsTile` with 24px colored icon squares + labels + trailing widgets
- Section headers are uppercase with `letterSpacing: 0.8` — consistent Material 3 style
**Polish score:** 8/10

### 14. Medicine Detail Screen
**Screenshot:** screenshots/14_medicine_detail.png
**Layout:** AppBar with medicine name + delete icon (red), header card (64px pill emoji circle + name 20px bold + strength + form badge + OpenFDA badge), Medicine Details section (generic name, manufacturer, category, quantity, expiry, added on, source), Reminders section (list with alarm icon + time + frequency + delete button, or empty state), Notes section, "Set Reminder" button, medical disclaimer.
**Issues found:**
- **Medicine header card is well structured** — row layout with emoji container + text column
- Delete icon in AppBar uses `Icons.delete_outline` red — clear danger affordance
- Detail rows use `_DetailRow` with label (12px secondary) left, value (14px semibold) right — partially inconsistent with other screens' label styling
- Reminders empty state uses `alarm_off_rounded` icon + text — helpful
- **"Add" button in Reminders section header** uses TextButton.icon — consistent pattern
- No edit functionality — only delete. Users can't edit strength, name, or form
**Polish score:** 7.5/10

### 15. Scan Screen
**Screenshot:** screenshots/15_scan_screen.png
**Layout:** Full-screen black background with camera feed, top bar (close button + title "Scan Medicine Box" + gallery button), OCR scan overlay (280×180 frame with animated cyan corner brackets), bottom controls (flash toggle, capture button, manual entry link), OCR/Barcode toggle switch.
**Issues found:**
- **Full-screen camera with overlay** — professional implementation
- Top bar title is white text on dark camera background — readable
- `_ScanOverlay` uses `Colors.black54` for the dimmed area with a transparent center cutout — correct
- **Corner brackets use `AppColors.scanAccent` (#00D4D4)** — this is a legacy teal color, NOT the standard primary blue. Inconsistent with the rest of the app's palette
- OCR/Barcode toggle (`_ModeToggle`) is a segmented control — well designed
- Manual Entry button has `Color(0x33000000)` background with teal border — dark semi-transparent style
- Flash toggle uses `Icons.flash_on/off` — clear
- Barcode mode uses `MobileScanner` package — shows live barcode detection
**Polish score:** 8/10

### 16. Caregiver Home
**Screenshot:** screenshots/16_caregiver_home.png
**Layout:** Same as patient Home but with additional "My Patient" card showing patient name + invite code section + "View Report →" link. FAB present. Health tip shown if patient has medicines.
**Issues found:**
- **Caregiver Home is essentially Patient Home + 1 extra card** — same greeting, same schedule, same FAB
- "My Patient" card uses `FutureBuilder` with direct Supabase queries — not reactive, doesn't update when data changes
- Invite code shown with monospace font + key icon — good visual distinction
- **No visual indicator that this is caregiver mode** — same blue theme, same bottom nav. Could use indigo accent on header
- The card color uses `caregiverLight` border — subtle difference
**Polish score:** 7/10

### 17. Caregiver Profile
**Screenshot:** screenshots/17_caregiver_profile.png
**Layout:** Same Profile screen with role badge showing "Caregiver" in indigo. Invite code section with large code display (32px, letter-spacing 8) + Copy Code + Rotate buttons.
**Issues found:**
- Role badge correctly shows caregiver with indigo styling — good
- Invite code section is clean — large centered code with caregiver color
- Copy button uses `Clipboard` + SnackBar feedback — functional
- Rotate button generates new code — proper UX
- **Stats grid shows caregiver-specific stats?** Need to verify — likely same 6 cells as patient
- **No caregiver-specific dashboard link** in this screen (it is in the MY PATIENT section)
**Polish score:** 7.5/10

### 18. Caregiver Dashboard
**Screenshot:** Not available (need to navigate from caregiver home)
**Layout:** AppBar "My Patient Dashboard" with patient name subtitle. Connection card (status + invite code), adherence card (30-day %, linear progress bar, Taken/Skipped/Missed stats), today's schedule card, medicine list card, calendar card, "Generate Report" button.
**Issues found:**
- Well-structured with multiple data cards
- Connection card shows "Patient Connected" green dot or "Waiting for Patient" amber dot — good visual status
- Invite code displayed large (28px bold, letter-spacing 8) — prominent
- **Adherence card uses the same pattern as History's adherence section** — consistent
- Calendar card is present as a placeholder — needs verification of actual calendar rendering
- "Generate Report" uses full-width `ElevatedButton.icon` with `caregiver` color — good CTA
**Polish score:** 7.5/10

### 19. Linked Patient Home
**Screenshot:** Not available (need to login as linked patient)
**Layout:** DARK theme — radial gradient background (amber glow on dark blue `#0A0E1A`), "Good Morning 🌅" greeting, "Today's Medicines" headline, medicine cards with dark card backgrounds (`#111827`), amber glow borders, large green "TOOK IT" gradient button and amber outlined "SKIP" button.
**Issues found:**
- **CRITICAL: This screen uses an entirely different visual theme** — dark backgrounds, amber accents, neon-style glow effects. This is a legacy dark theme remnant that hasn't been migrated to the new light palette
- Color tokens are hardcoded in a private `_LP` class instead of using `AppColors`
- Uses emojis in greeting ("🌅", "🌤️", "🌙") — inconsistent with patient app's text-only greeting
- The "TOOK IT" button uses a green gradient (`#00C896` → `#00A878`) with glow shadow — gaming aesthetic
- The "SKIP" button has amber border on transparent bg — matches dark theme
- **Bottom label uses `FutureBuilder`** to resolve caregiver name — non-reactive pattern
- When all doses taken, shows "All done for today!" card with green-tinted dark bg — actually a nice celebratory state, but visually out of place with the rest of the app
- No FAB, no bottom navigation
**Polish score:** 4/10 (fails consistency)

### 20. Email Confirmation Screen
**Screenshot:** Not available (requires new registration)
**Layout:** DARK theme — `AppBackground` parent, dark scaffold background, teal-cyan (`#00D4D4`) circular icon container with glow effect, "Check your email" text in white 28px bold, email displayed in muted teal text, "Resend confirmation email" outlined button (teal border), "Back to login" link.
**Issues found:**
- **CRITICAL: Uses dark/teal theme** — this is an un-migrated legacy screen
- Icon color (`#00D4D4`) and button border (`#00D4D4`) use the old neon teal accent, not the `AppColors.primary` blue
- Text body uses `#8FA3B8` — a dark-theme muted color, not standard `AppColors.textSecondary` (`#6B7C93`)
- The `AppBackground` wraps a `Scaffold(backgroundColor: Colors.transparent)` — the `AppBackground` gradient (primaryLight → background) is light, but the screen is rendered dark
- **Inconsistent with register/login flow** — user goes from light screens to this dark screen abruptly
- "Resend" button is `OutlinedButton` with teal styling — no theme-based styling
- The glow effect (`blurRadius: 40, spreadRadius: 10`) around the icon is heavy and visually aggressive
**Polish score:** 3/10 (un-migrated legacy)

### 21. Enter Code Screen
**Screenshot:** screenshots/21_enter_code.png, screenshots/21_enter_code_error.png
**Layout:** Light theme (correct). Icon container with `linkedLight` bg + `linked` amber icon. "Enter Your Code" title, instruction text, 6 OTP boxes (44×54px each, linked-colored text, auto-advance), "Link to Caregiver" amber button, help text at bottom. Error banner shown on invalid code.
**Issues found:**
- **This screen IS properly migrated to the light theme** — consistent with rest of app
- OTP boxes have `surfaceVariant` fill with `border` border — clean
- Auto-focus advance between boxes works (code: `onChanged` advances to next `FocusNode`)
- "Link to Caregiver" button uses `AppColors.linked` (#F5A623) — correct amber accent
- Error banner uses `dangerLight` bg + red text + error icon — consistent with register/login error patterns
- **OTP boxes don't visually indicate completion** — no "all filled" state change
- Backspace handling goes to previous field — good UX
**Polish score:** 8/10

### 22. Invite Patient Screen
**Screenshot:** screenshots/22_invite_patient.png
**Layout:** Light theme. Caregiver-indigo icon container (72px, `caregiverLight` bg), "Your Invite Code" title, instruction text, code display (36px bold, letter-spacing 10, caregiver color on `caregiverLight` bg), "Share Code" filled button (caregiver indigo), "Copy Code" outlined button, "Go to Home →" link.
**Issues found:**
- **Properly migrated to light theme** — consistent
- Code display is the most prominent element (36px font, 20px vertical padding) — good visual hierarchy
- Share button uses `SharePlus.instance.share()` — actual system share sheet integration
- Copy button copies to clipboard with SnackBar confirmation (green bg) — good feedback
- "Go to Home →" uses `textSecondary` color — subtle, de-emphasized
- **No loading state on share** — share is instant (system sheet)
- **The instruction text is very long** — may need to scroll on smaller screens
**Polish score:** 8/10

---

## Cross-Screen Issues

1. **Dual Theme Inconsistency (P0):** Email Confirmation screen (#20) and Linked Patient Home (#19) use the old dark/neon theme with teal/amber accents. These break the user's trust in the app's visual identity immediately after registration or when switching roles. The Email Confirmation screen is the FIRST thing new users see after registering — it must be migrated.

2. **AppBar Bottom Divider Pattern:** Most screens use `AppBar(bottom: PreferredSize(child: Divider(height: 1, color: AppColors.border)))` — some screens omit this (Splash, Welcome). The pattern is consistent where applied.

3. **Loading Indicators:** All async operations use `CircularProgressIndicator(strokeWidth: 2)` — some use `color: AppColors.primary`, others use default color. Inconsistent.

4. **Toast/SnackBar Styling:** Success SnackBars use green background with floating behavior and rounded corners. Error messages use inline `_ErrorBanner` containers with `dangerLight` background. Two different error display patterns coexist.

5. **Emoji Usage vs Vector Icons:** Schedule cards use `'💊 ${medicineName}'`, health metrics don't use emojis, profile stats use vector icons. No consistent standard.

6. **Empty States:** Three different empty state patterns exist:
   - Home: Full card with icon + title + description + CTA button (best)
   - History: Raw emoji "💊" + text (adequate)
   - Medicine Detail reminders: `alarm_off_rounded` icon + text (good)

7. **NavigationBar Style:** Bottom nav consistently uses `NavigationBar` with `alwaysShow` labels — correct Material 3 pattern.

8. **Section Card Pattern:** Most sections use the same card style (surface bg, 16px radius, 1px border, subtle shadow) — highly consistent.

---

## Component Consistency Audit

### Buttons
- **Primary (`ElevatedButton`):** `AppColors.primary` bg, white text, 14px radius, 54px height (theme default). Consistent across all screens.
- **Outlined (`OutlinedButton`):** Primary border, primary text, 14px radius, same height. Consistent.
- **Success (Took It):** `AppColors.success` bg, white text, 10px radius, 40px height (overridden in `_PendingCard`). Inconsistent radius vs theme default.
- **Caregiver/Indigo:** Overridden with `AppColors.caregiver` directly (not using theme). Visual consistency OK but bypasses theme system.
- **Linked/Amber:** Same pattern — direct color override on the widget.
- **Loading state:** 22px CircularProgressIndicator with white color replaces button text. Consistent pattern.

### Cards
- Standard: `AppColors.surface` bg, `BorderRadius.circular(16)`, 1px `AppColors.border` border, subtle shadow. **Very consistent.**
- Section cards in Add Medicine: Same plus 3px colored left-border accent. Good variation.
- History entries: 12px radius instead of 16px. Inconsistent.
- AlertDialog (delete confirmation): Uses default theme, not customized. Plain.

### Typography
- **Headings:** `AppTypography.h1` (28px bold) on Welcome/Login, `h2` (24px semibold) on Register title, `h3` (20px semibold) on section headers. Consistent hierarchy.
- **Body:** 16px regular Inter throughout. `bodySmall` 14px for secondary text. Consistent.
- **Labels:** 14px semibold for form labels and card titles. Consistent.
- **Disclaimer:** 10px (Welcome) vs 12px (Medicine Detail/Add Medicine). Inconsistent.
- **Inter font via Google Fonts** — consistent across all screens.

### Colors
- **Primary blue (#2D7DD2):** Used consistently as the main action color.
- **Success green (#27AE60):** Used for taken doses, positive confirmations, progress bar.
- **Warning amber (#F39C12):** Used for warnings, missed doses, caution states.
- **Danger red (#E74C3C):** Used for errors, delete actions, missed doses.
- **Caregiver indigo (#5B6EF5):** Used for caregiver-specific elements.
- **Linked amber (#F5A623):** Used for linked patient elements.
- **Rogue colors:**
  - `#00D4D4` (scanAccent/teal) — used in Scan screen and Email Confirmation
  - `#00C896` → `#00A878` gradient — used in Linked Patient "TOOK IT" button
  - `#0A0E1A`, `#111827`, `#FFB800` — hardcoded in `_LP` class for Linked Patient
  - `#8FA3B8` — hardcoded in Email Confirmation
- **Overall:** The main app is cohesive; the legacy screens introduce 5+ rogue colors.

### Spacing
- **Horizontal padding:** 24px on auth screens, 16px on main tab screens. Auth screens get more breathing room — intentional.
- **Card padding:** 16px everywhere. Consistent.
- **Section spacing:** `SizedBox(height: 20)` or `AppDimensions.md` (16px). Inconsistent — some use literals, some use constants.
- **Between form fields:** 12px. Consistent.
- **Bottom padding:** Main tab screens have 100px bottom space for nav bar. Add Medicine has 120px. Inconsistent.

---

## Empty States Audit

| Screen | Empty State | Rating |
|--------|------------|--------|
| Home (no medicines) | Full card: icon + "No medicines yet" + description + CTA button | 9/10 |
| History (no entries) | Raw emoji + "No history yet" + description | 6/10 |
| Medicine Detail Reminders | `alarm_off_rounded` icon + "No reminders set" + "Tap + Add to create one" | 8/10 |
| Caregiver Dashboard (no patient) | Connection card shows "Waiting for Patient" | 7/10 |
| Caregiver Dashboard (no data) | "Patient activity will appear here" text | 7/10 |

---

## Accessibility Concerns

1. **Disclaimer text at 10px** on Welcome screen — too small for users over 50. Should be minimum 12px.
2. **Button disabled state** uses `surfaceVariant` bg + `textTertiary` text — contrast ratio is ~3:1, below WCAG AA minimum of 4.5:1.
3. **Form field labels** are 12px `textSecondary` — readable but small.
4. **No high-contrast mode** support detected.
5. **No font scaling** support — all sizes are hardcoded pixel values rather than using `MediaQuery.textScaleFactor`.
6. **OTP boxes** (44×54px) may be small for users with motor impairments.
7. **Toast messages** (SnackBars) auto-dismiss after 2 seconds — may be too fast for slow readers.
8. **Color-only indicators** — status is communicated solely through color (green/amber/red) without accompanying text labels in some places.
9. **No accessibility labels** found on icon-only buttons (e.g., delete icon in AppBar).

---

## What Still Looks Basic/Unpolished

1. **Dark/legacy screens** are the most obvious unpolished elements — they look like a different app entirely
2. **Raw emoji** used throughout instead of custom vector icons (💊, 🔥, ✅, 🌅, etc.)
3. **Default Cupertino pickers** in Health bottom sheet — functional but not themed to match the app's design language
4. **Google sign-in button** uses `g_mobiledata` icon instead of the official Google logo
5. **`ponytail` comments** throughout the codebase — these are "to do later" markers in production code
6. **Dark mode toggle** on Profile screen does nothing — `darkTheme = lightTheme`
7. **No skeleton loading states** — all loading is `CircularProgressIndicator` centered
8. **AlertDialog in delete** uses default Material theme, not customized to match app branding
9. **No haptic feedback** on button presses, toggles, or completed actions
10. **Tab bar has no visual feedback** when switching — hard swap via `IndexedStack`

---

## Priority Fix List

### P0 — Critical (looks broken)
1. **Migrate Email Confirmation screen** to light theme — currently dark/teal legacy
2. **Migrate Linked Patient Home** to light theme — currently dark/amber legacy with `_LP` hardcoded colors
3. **Either implement dark mode or remove the toggle** — `darkTheme = lightTheme` is misleading

### P1 — High (looks unfinished)
4. **Standardize error display** — choose between inline `_ErrorBanner` and SnackBar patterns
5. **Replace raw emojis** with custom vector icons (💊 → `medication_rounded`, 🔥 → `local_fire_department`, etc.)
6. **Remove `ponytail` comments** from production code
7. **Implement skeleton loading** instead of plain `CircularProgressIndicator`
8. **Make Cupertino pickers match app theme** — currently default white/blue iOS style

### P2 — Medium (could be better)
9. **Add backdrop blur to modal bottom sheets** — currently transparent scaffold bg
10. **Standardize card radius** — history entries use 12px vs 16px everywhere else
11. **Fix scan screen corner brackets** to use `primary` blue instead of `scanAccent` teal
12. **Add undo option** after marking a dose as taken
13. **Implement password reset** instead of the "contact support" placeholder
14. **Add edit functionality** for medicines (currently delete-only)
15. **Standardize loading indicator colors** — some use `AppColors.primary`, some use default

### P3 — Low (nice to have)
16. **Add haptic feedback** on important interactions
17. **Customize AlertDialog** to match app theme
18. **Increase disclaimer font** from 10px to 12px
19. **Improve disabled button contrast** to meet WCAG AA
20. **Add app version to Welcome screen**
21. **Show "all fields complete" visual state on OTP entry**

---

## Specific Pixel-Level Notes

- **OTP box width (44px)** vs height (54px) — tall and narrow. Standard OTP boxes are 48-50px square.
- **Role card left border (4px)** — slightly thinner than the standard section accent bar (3px). Minor inconsistency.
- **Bottom sheet handle (40×4px)** — same across all sheets. Correct.
- **FAB size (60px)** from `AppDimensions.fabSize` — matches Material 3 spec.
- **Progress card border shadow** — `Colors.black.withOpacity(0.06)`, blur 12, offset (0,4). Very subtle, correct.
- **Section header accent bar (3×18px)** — consistent across all sectioned screens.
- **Adherence % font (48px)** — large and impactful. Good hierarchy.
- **Avatar CircleAvatar radius (44px)** with edit overlay (28px circle). Good proportion.
- **NavigationBar indicator** uses `primaryLight` — slight tint on selected item background.
- **Filter chip padding** — `horizontal: 8, vertical: 4`. Could be slightly larger for touch targets.
- **Role badge padding** — `horizontal: 14, vertical: 6`. 20px border radius. Good pill shape.

---

## Comparison to Reference Apps

- **MyTherapy (market leader):** MediFlow has cleaner typography and more modern card design. MyTherapy uses more saturated colors and has a denser layout. MediFlow's empty states are better. MediFlow lacks MyTherapy's gamification (streaks, achievements, points). **MediFlow visual polish ≈ MyTherapy.**

- **Apple Health:** Apple Health is the gold standard — minimal, system-native, perfectly consistent typography, no emojis, adaptive dark/light mode. MediFlow's health tracking screen is similar in concept (2-column grid of metrics) but uses more visual weight (colored icon circles). **MediFlow is 1 step behind Apple Health** — mainly due to the legacy dark screens and emoji usage.

- **Medisafe:** MediFlow's card-based medicine schedule is cleaner than Medisafe's tabular approach. Medisafe uses more color coding per medicine. MediFlow's bottom navigation is clearer. Medisafe has better medication interaction warnings. **MediFlow visual polish > Medisafe** for the modern screens; legacy screens are worse.

---

## Recommendations for Next Sprint

1. **Highest visual impact: Migrate Email Confirmation and Linked Patient Home to the light theme.** This single change removes the biggest visual inconsistency. Allocate 2 days for both screens. Use `AppColors` tokens, standard card styling, and remove glow effects.

2. **Second highest: Audit and replace all raw emoji strings** with Material Icons or custom SVG icons. Target specifically: 💊 (medication_rounded), 🔥 (local_fire_department), ✅ (check_circle), 🌅/🌤️/🌙 (use text-only greetings). This makes the app feel professionally designed rather than chat-app casual.

3. **Third: Remove `ponytail` comments and `darkTheme = lightTheme` workaround.** Either implement dark mode properly or remove the toggle from Profile. A non-functional toggle damages user trust.

4. **Fourth: Implement skeleton loading states** for all async content (Home schedule, Health metrics, History list, Profile data). Replace `CircularProgressIndicator` with shimmer-based card skeletons. This is the single biggest "unfinished" visual cue.

5. **Fifth: Standardize the error/feedback system.** Choose one pattern (inline banner vs SnackBar) and apply it throughout. Add haptic feedback to confirmations. Add undo to dose marking. These micro-interactions are what separate an MVP from a polished product.
