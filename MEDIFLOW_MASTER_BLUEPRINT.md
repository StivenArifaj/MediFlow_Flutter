# 🏥 MEDIFLOW — COMPLETE FLUTTER BUILD BLUEPRINT
> **Version:** 2.0 (Flutter Rebuild)
> **Date:** February 19, 2026
> **Target:** iOS & Android (Flutter)
> **Primary Market:** Albania → Global
> **Author:** Master Concept Document for Cursor / OpenCode

---

## 📌 EXECUTIVE SUMMARY

MediFlow is a **privacy-first, AI-assisted medication management app** built in Flutter. It helps patients and caregivers organize medicines, set smart reminders, track health vitals, and monitor adherence — all without requiring internet access for core functionality. Data lives on the device first, Firebase second (backup only).

### Core Principles
1. **Offline-first** — Everything works without internet
2. **Privacy-first** — Local SQLite storage, Firebase only for backup
3. **Medical safety** — Never advises, only organizes
4. **Dual persona** — Adapts UI based on whether user is a Patient or Caregiver
5. **Albanian-first** — Designed for Albanian market, globally scalable

---

## 🎯 USER PERSONAS

### Persona 1: The Patient (50+ years old)
- Takes multiple daily medications for chronic conditions
- Forgets doses often
- May not be tech-savvy
- Needs: simple reminders, easy medicine log, health tracking
- Example: Elderly Albanian with hypertension taking 3+ daily medicines

### Persona 2: The Caregiver (15–49 years old)
- Manages medicines for a family member (elderly parent, child)
- Needs to monitor adherence remotely or in-person
- More tech-savvy
- Needs: full control, schedule setup, adherence reports, data export
- Example: Adult child managing elderly parent's medication schedule

---

## 🗺️ APP FLOW OVERVIEW

```
App Launch
    │
    ├── First Time → Onboarding Flow (3 slides) → Role Selection (Patient / Caregiver)
    │   → Register Screen → Home
    │
    └── Returning User → Splash → Check session → Home (Tab Navigator)
                                                → Auth Stack (if no session)
```

---

## 📱 ALL SCREENS (16 Total)

### Group 1: Pre-Auth Screens

| # | Screen | Purpose |
|---|--------|---------|
| 1 | Splash Screen | Branded loading, session check |
| 2 | Onboarding Screen | 3-slide feature walkthrough (first install only) |
| 3 | Role Selection Screen | Choose: "I am a Patient" or "I am a Caregiver" |
| 4 | Welcome Screen | Login / Register entry point |
| 5 | Register Screen | Create account (name, email, password, role confirmed) |
| 6 | Login Screen | Email + password login |

### Group 2: Main App (Bottom Tab Navigation — 4 Tabs)

| # | Screen | Tab | Role Visibility |
|---|--------|-----|----------------|
| 7 | Home Screen | 🏠 Home | Both |
| 8 | Health Dashboard | ❤️ Health | Both |
| 9 | History Screen | 📊 History | Both |
| 10 | Profile Screen | 👤 Profile | Both |

### Group 3: Stack Screens (pushed from tabs)

| # | Screen | Accessed From | Role |
|---|--------|--------------|------|
| 11 | Scan Screen | Home FAB | Both |
| 12 | Add Medicine Screen | Home FAB / Scan result | Both (Caregiver fills for Patient) |
| 13 | Medicine Detail Screen | Medicine card tap | Both |
| 14 | Reminder Setup Screen | Medicine Detail / Add Medicine | Both |
| 15 | Caregiver Dashboard | Profile → Manage Patient | Caregiver only |
| 16 | Data Export / Share Screen | Profile → Export | Both |

---

## 🎭 ROLE-BASED EXPERIENCE

When user selects their role during onboarding/registration, the app adapts:

### Patient Mode
- Home shows simplified "Today's Medicines" as primary focus
- Large, easy-to-tap "Mark as Taken" / "Skip" buttons
- Health Dashboard fully available
- Cannot see Caregiver Dashboard
- Minimal complexity — fewer options shown

### Caregiver Mode
- Home shows full medicine management dashboard
- Can add/edit/delete medicines and reminders freely
- Caregiver Dashboard available (manage one "patient profile")
- Access to detailed adherence stats
- Can export PDF/JSON for doctor visits
- More advanced options visible

> Note: Caregiver manages a **single linked patient profile** (V1). Multi-patient support is V2.

---

## 🗂️ NAVIGATION ARCHITECTURE

```
Root
├── SplashScreen
│
├── AuthStack (unauthenticated)
│   ├── OnboardingScreen (first launch only, stored flag in SharedPreferences)
│   ├── RoleSelectionScreen
│   ├── WelcomeScreen
│   ├── RegisterScreen
│   └── LoginScreen
│
└── MainTabNavigator (authenticated)
    ├── Tab 1: HomeScreen
    │   ├── ScanScreen (fullscreen)
    │   ├── AddMedicineScreen
    │   ├── MedicineDetailScreen
    │   └── ReminderSetupScreen
    │
    ├── Tab 2: HealthScreen
    │   └── HealthDetailScreen (per-metric history chart)
    │
    ├── Tab 3: HistoryScreen
    │
    └── Tab 4: ProfileScreen
        ├── CaregiverDashboardScreen
        └── DataExportScreen
```

---

## 📐 DESIGN SYSTEM

### Color Palette

```dart
// PRIMARY COLORS
primary:        #00D4D4  // Vibrant teal/cyan — buttons, active states, accents
primaryDark:    #00A3A3  // Darker teal — pressed states, gradients

// BACKGROUND (Dark Mode — DEFAULT)
bgDark:         #0D1B2A  // Deep navy — main background
bgCard:         #162032  // Card surface
bgCardLight:    #1E2D42  // Slightly elevated card
bgInput:        #1A2B3C  // Input field background

// BACKGROUND (Light Mode)
bgLight:        #F0FAFA  // Light cyan tint
bgCardLight_lm: #FFFFFF
bgCardMid_lm:   #F5FAFA

// TEXT
textPrimary:    #FFFFFF  // White — headings (dark mode)
textSecondary:  #8FA3B8  // Muted blue-gray — subtitles, labels
textPrimary_lm: #0D1B2A  // Dark navy (light mode)
textSecondary_lm:#5A7A96

// STATUS COLORS
success:        #10B981  // Emerald green — taken, streaks
warning:        #F59E0B  // Amber — late, snooze
error:          #EF4444  // Red — missed, delete
info:           #3B82F6  // Blue — neutral info

// PREMIUM
premiumFrom:    #8B5CF6  // Purple
premiumTo:      #EC4899  // Pink

// CAREGIVER ACCENT
caregiverAccent:#6366F1  // Indigo — caregiver-specific UI elements
```

### Gradients
```dart
// Header gradient (top of Home/Health screens)
headerGradient:    LinearGradient([#0D1B2A → #162032], top→bottom)

// Button gradient (primary CTAs)
primaryGradient:   LinearGradient([#00D4D4 → #00A3A3], left→right)

// Premium card gradient
premiumGradient:   LinearGradient([#8B5CF6 → #EC4899], 135°)

// Success card gradient
successGradient:   LinearGradient([#10B981 → #059669], left→right)

// Health tip card gradient
tipGradient:       LinearGradient([#10B981 → #00D4D4], 135°)
```

### Typography
```dart
// Font: Inter (Google Fonts)
// Fallback: System default

displayLarge:  32px, Bold,     White
displayMedium: 28px, Bold,     White
headlineLarge: 24px, Bold,     White
headlineMedium:20px, SemiBold, White
titleLarge:    18px, SemiBold, White
titleMedium:   16px, Medium,   White
bodyLarge:     16px, Regular,  White
bodyMedium:    14px, Regular,  textSecondary
bodySmall:     12px, Regular,  textSecondary
labelLarge:    14px, SemiBold, primary (teal)
```

### Spacing & Radius
```dart
// Spacing
xs:   4px
sm:   8px
md:   16px
lg:   24px
xl:   32px
xxl:  48px

// Border Radius
radiusSm:    8px
radiusMd:    12px
radiusLg:    16px
radiusXl:    24px
radiusFull:  100px (pill buttons)

// Shadows
shadowSmall:  BoxShadow(color: black.15, blur: 8, offset: (0,2))
shadowMedium: BoxShadow(color: black.20, blur: 16, offset: (0,4))
shadowTeal:   BoxShadow(color: primary.30, blur: 20, offset: (0,4))
```

### Component Standards

**Cards:** `borderRadius: 16px`, `color: bgCard`, `padding: 16px`, optional teal left border accent

**Buttons:**
- Primary: Full-width pill, teal gradient, white text, 52px height
- Secondary: Outlined, teal border, teal text
- Danger: Soft red/salmon fill (#EF4444 at 20% opacity), red text
- Ghost: No background, teal text

**Inputs:** Dark fill (#1A2B3C), 12px radius, teal focus border, character counter for long fields

**Chips (form selector, days):** Rounded pills, teal active, dark inactive, smooth tap animation

**FAB:** 60px circle, teal fill, white icon, teal glow shadow, bottom-right position

**Bottom Nav Bar:** Dark (#0D1B2A), teal active icon + label, inactive muted gray

---

## 📱 SCREEN-BY-SCREEN SPECIFICATION

---

### 1. SPLASH SCREEN

**Layout:**
- Full dark background (#0D1B2A)
- Centered: MediFlow logo (teal gradient icon) + wordmark
- Tagline: "Your Smart Medicine Companion" (Albanian: "Asistenti juaj i ilaçeve")
- Animated: Logo pulses in, text fades in
- After 2s: Check session → navigate accordingly

**Logic:**
- Check SharedPreferences for `hasSeenOnboarding` → if false, go to Onboarding
- Check stored session → if valid user → go to MainTab
- If no session → go to Welcome

---

### 2. ONBOARDING SCREEN

**Shown:** First install only. Stored flag so it never shows again.

**Layout:** PageView with 3 pages + dot indicators + "Skip" button (top right) + "Next" / "Get Started" (last page)

**Page 1 — Track Medicines**
- Illustration: Animated pill/medicine icon
- Title: "Track All Your Medicines"
- Body: "Organize every medicine in one place. Never forget a dose again."

**Page 2 — Smart Reminders**
- Illustration: Bell/notification animation
- Title: "Smart Reminders"
- Body: "Get personalized notifications at exactly the right time."

**Page 3 — Your Health, Your Data**
- Illustration: Health dashboard graphic
- Title: "Monitor Your Health"
- Body: "Track 13 vital signs and see your adherence improve over time."

**CTA on last page:** "Get Started →" → goes to RoleSelectionScreen

---

### 3. ROLE SELECTION SCREEN

**Layout:**
- Title: "Who are you?" (Albanian: "Kush jeni ju?")
- Subtitle: "Help us personalize your experience"
- Two large selection cards side by side:

**Card 1 — Patient**
- Icon: 💊 Person icon
- Label: "I am a Patient"
- Subtitle: "I manage my own medicines"
- Teal border when selected

**Card 2 — Caregiver**
- Icon: 🤝 Hands/care icon (indigo accent)
- Label: "I am a Caregiver"
- Subtitle: "I help someone else with their medicines"
- Indigo border when selected

**CTA:** "Continue" button (disabled until selection made) → RegisterScreen

**Logic:** Role stored in user record + SharedPreferences

---

### 4. WELCOME SCREEN

**Layout:**
- Dark background with subtle animated gradient blob in top
- MediFlow logo centered (large, 80px)
- App name (42px Bold)
- Tagline (16px, muted)
- 4 mini feature chips: "OCR Scan", "Smart Reminders", "13 Health Metrics", "Private & Offline"
- Primary button: "Create Account" → Register
- Text link: "Already have an account? Log In" → Login
- Bottom: Medical disclaimer footnote (tiny, muted)

---

### 5. REGISTER SCREEN

**Layout:**
- Teal gradient header bar with title "Create Account" + back arrow
- Form fields (all dark input style):
  - Full Name (text, required)
  - Email (email keyboard, required)
  - Password (obscured, required, min 6 chars)
  - Confirm Password (obscured, required, must match)
  - Role displayed as read-only badge (from previous step)
- "Create Account" primary button
- On success → auto-login → navigate to MainTab

**Validation:**
- Real-time validation with error text below each field
- Email regex check
- Password strength indicator (weak/medium/strong color bar)
- Duplicate email check against SQLite

**Logic:**
- Hash password with SHA-256 (crypto package)
- Save to SQLite users table
- Create Firebase Auth account (for sync)
- Save session to SharedPreferences
- Navigate to MainTabNavigator

---

### 6. LOGIN SCREEN

**Layout:**
- Teal gradient header bar, "Welcome Back" title
- Email + Password fields
- "Log In" primary button
- "Forgot Password?" text link (V2 — for now just shows "Contact support")
- "Don't have an account? Register" link

**Logic:**
- Hash input password, compare with stored hash in SQLite
- Firebase sign-in attempt (if online)
- Session persistence via SharedPreferences
- Navigate to MainTab on success

---

### 7. HOME SCREEN ⭐

**The main screen — most important to get right.**

**Layout (Patient Mode):**
```
┌─────────────────────────────────────┐
│ [Header: Dark gradient]             │
│  Good Morning 👋                    │
│  [User Name]         [Avatar circle]│
│                                     │
│  ┌──────────┐ ┌──────────┐ ┌──────┐│
│  │    1     │ │    0     │ │  0   ││
│  │ Medicines│ │  Today   │ │Remind││
│  └──────────┘ └──────────┘ └──────┘│
├─────────────────────────────────────┤
│ [Body: Scrollable dark bg]          │
│                                     │
│ 💊 Today's Schedule                 │
│ ┌─────────────────────────────────┐ │
│ │ [Medicine name]  08:00 AM       │ │
│ │ [✓ Take] [– Skip] [⏰ Snooze]  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 🔗 My Medicines              See All│
│ ┌─────────────────────────────────┐ │
│ │ [💊] Paracetamol    Tablet  >  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 💡 Health Tip                  │ │
│ │ Take medicines at the same time │ │
│ │ each day for better adherence   │ │
│ └─────────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
                              [📷 FAB]
[🏠 Home] [❤️ Health] [📊 Hist] [👤 Prof]
```

**Greeting Logic:**
- 05:00–11:59 → "Good Morning 👋"
- 12:00–17:59 → "Good Afternoon 🌤️"
- 18:00–22:59 → "Good Evening 🌙"
- 23:00–04:59 → "Good Night 🌙"

**Quick Stats Row:** Animated number display, taps navigate to relevant screen

**Today's Schedule:**
- Shows reminders due today, sorted by time
- Each card: medicine name, time, status pill (Pending/Taken/Skipped/Missed)
- Action buttons:
  - ✅ "Take" → marks as taken, logs to history, shows success animation
  - ⏭️ "Skip" → marks skipped, logs to history
  - ⏰ "Snooze" → bottom sheet with 5/10/15/30 min options → reschedules notification
- Empty state: "No medicines scheduled today — Add your first medicine"

**My Medicines Section:**
- Search bar (top, filters in real-time)
- List of medicine cards, each showing:
  - Pill icon (colored by form type)
  - Medicine name (bold)
  - Form type (Tablet, Capsule, etc.)
  - Next reminder time (if set)
  - Chevron right
- Tap → MedicineDetailScreen
- Swipe left → Delete (with confirmation)
- "See All →" shows full paginated list

**Health Tip Card:** Teal gradient card, rotates daily from a pool of 30 tips

**FAB (Floating Action Button):**
- Single teal camera icon (opens scan menu)
- Press → shows mini FAB menu expanding upward:
  - 📷 "Scan Medicine Box"
  - ✏️ "Add Manually"

**Caregiver Mode additions to Home:**
- Header shows "Managing: [Patient Name]" badge in indigo
- Adherence percentage ring shown in header area
- Quick actions: "View Patient Report" button

---

### 8. SCAN SCREEN

**Layout:**
- Fullscreen (no bottom tab bar)
- Dark overlay except scan frame
- Top: "Scan Medicine Box" title, "Align medicine name within the frame" subtitle
- Center: Animated cyan corner brackets (scan frame, 280×180px)
- Bottom controls row:
  - ⚡ Flash toggle (icon, toggles on/off)
  - ⭕ Capture button (large white circle with teal ring, 72px)
  - T "Manual Entry" (text, navigates to AddMedicine)
- Gallery import button (top right corner)

**Scan Technology:** Google ML Kit Text Recognition (`google_mlkit_text_recognition`) — FREE, fully offline, no API key needed, on-device processing.

**OCR Processing Flow:**
```
User captures photo
    → ImageProcessor: resize to 1024px max, enhance contrast
    → ML Kit TextRecognizer: extract all text blocks
    → MediFlowParser: smart parsing of extracted text:
        - Name: largest/boldest text block, first prominent line
        - Strength: regex → (500mg, 10ml, 1g, 250mcg patterns)
        - Form: keyword match (tablet, capsule, syrup, drops, cream, inhaler, injection)
        - Manufacturer: after keywords (manufactured by, product of, marketed by)
        - Expiry: regex (EXP, Exp, Best Before + date patterns)
        - Quantity: regex (10 tablets, 30 capsules)
    → OpenFDA API query with parsed name (for enrichment if online)
    → Results pre-filled in AddMedicineScreen for user review/confirmation
```

**States:**
- Scanning: Live camera + frame
- Capturing: Brief flash animation
- Processing: Loading indicator "Analyzing medicine..."
- Success: Results shown in AddMedicine (pre-filled)
- No text detected: "Couldn't read this image — try better lighting or Manual Entry"
- Medicine not found in FDA: Still shows parsed OCR data, user confirms

**Barcode Scanning (secondary feature):**
- If user points at barcode → auto-detect and query OpenFDA by NDC barcode
- Uses `mobile_scanner` Flutter package (free, supports both iOS and Android)
- Switch between OCR/Barcode mode via toggle button in scan UI

---

### 9. ADD MEDICINE SCREEN

**Header:** Teal gradient, "Add Medicine" title, back arrow

**Form Sections:**

**Section 1: Basic Information**
- Verified Name* (required, max 100 chars, character counter)
- Brand Name (optional, max 100)
- Generic Name (optional, max 100)
- Manufacturer (optional, max 100)

**Section 2: Medicine Details**
- Strength (text, "e.g. 500mg", max 50)
- Form selector (horizontal scrollable chip group):
  Tablet | Capsule | Liquid | Injection | Cream/Ointment | Drops | Inhaler | Patch | Spray | Other
- Quantity (number input, optional)
- Expiry Date (date picker, optional)
- Category (text field, e.g., Pain Relief, Antibiotic)

**Section 3: Notes & Memos**
- Notes (multiline, max 500 chars)
- Personal alias/nickname for medicine (optional)

**Section 4: Reminders**
- Subheader: "Set reminder times now, or add them later"
- 4 preset quick-add buttons:
  - ☀️ Morning (08:00)
  - 🌤️ Afternoon (14:00)
  - 🌙 Evening (20:00)
  - 🛏️ Before Bed (22:00)
- "Custom time" + button → opens time picker
- Added times shown as removable chips (e.g., "08:00 ✕")
- Max 5 reminder times

**Bottom sticky section:**
- ⚠️ Medical Disclaimer card (always visible)
- "Confirm & Add Medicine" primary button

**Data Source badge** (auto-set): "OpenFDA ✓" if enriched by API, "Manually Added" if not

**Logic:**
- On save: write to SQLite medicines table
- Schedule local notifications for each reminder time
- If Firebase online: sync to Firestore backup
- Navigate back to Home with success snackbar

---

### 10. MEDICINE DETAIL SCREEN

**Header:** Teal gradient header with medicine name + back arrow

**Layout:**
```
┌─ Medicine card ──────────────────────┐
│ [Pill icon]  Paracetamol            │
│              [Tablet badge] [FDA badge]│
└─────────────────────────────────────┘

┌─ Medicine Details card ─────────────┐
│ Form:              Tablet           │
│ Strength:          500mg            │
│ Generic Name:      Acetaminophen    │
│ Brand Name:        Paracetamol      │
│ Manufacturer:      Hormona          │
│ Active Ingredients: Acetaminophen   │
│ Expiry Date:       12/2027          │
│ Quantity:          10 tablets       │
│ Category:          Pain Relief      │
│ Added On:          Feb 13, 2026     │
│ Source:            Manually Added   │
└─────────────────────────────────────┘

┌─ Reminders ─────────────── [+ Add] ─┐
│ ⏰ 08:00 — Every day    [Edit] [✕] │
│ ⏰ 20:00 — Every day    [Edit] [✕] │
│                                     │
│ (empty state: "No reminders set")   │
└─────────────────────────────────────┘

┌─ Notes card ────────────────────────┐
│ "Take with food"                    │
└─────────────────────────────────────┘

┌─ Medical Disclaimer ────────────────┐
│ ⚠️ MediFlow is a medication         │
│ organization tool only...           │
└─────────────────────────────────────┘

[Set Reminder]   ← teal button
[Edit Medicine]  ← outlined button
[Delete Medicine]← danger/red button
```

**Actions:**
- Set Reminder → ReminderSetupScreen
- Edit → opens AddMedicine pre-filled with existing data
- Delete → confirmation dialog → deletes medicine, reminders, history entries → navigate back

---

### 11. REMINDER SETUP SCREEN

**Header:** Teal gradient, "Set Reminder" title

**Step 1: Choose Time**
- 4 preset buttons (pill-shaped, teal active):
  ☀️ Morning (08:00) | 🌤️ Afternoon (14:00) | 🌙 Evening (20:00) | 🛏️ Bedtime (22:00)
- "Add Custom Time" button → opens Flutter time picker
- Added times shown as removable chips below

**Step 2: Frequency**
- Radio-style options:
  - Every day (default)
  - Specific days → reveals Mon/Tue/Wed/Thu/Fri/Sat/Sun toggle chips
  - Every X days → number input (every 2 days, every 3 days, etc.)
  - As needed (no automatic reminders)

**Step 3: Duration**
- Radio options:
  - Ongoing (no end date)
  - Until specific date → date picker
  - For X days → number input

**Step 4: Additional Options**
- Snooze enabled: toggle (default ON)
- Snooze duration: 5 / 10 / 15 / 30 min selector
- Sound: toggle (default ON)
- Vibration: toggle (default ON)

**Bottom:**
- "Save Reminder" primary button
- Logic: saves to SQLite reminders table, schedules via flutter_local_notifications

---

### 12. HEALTH SCREEN ❤️

**Header:** Dark gradient header (no teal — subtle), "Health Dashboard" title, "Track your vital signs" subtitle

**Two View Modes (segmented control):**
- **Grid View** (default): 2-column grid of metric cards
- **List View**: Full list with latest value + mini sparkline

**Grid View Layout:**
Each card (half-width):
```
[Colored icon]  [Type Name]
[Value]  [Unit]
[Date of last entry]
```

**13 Health Metrics:**

| Metric | Unit | Icon Color | Icon |
|--------|------|-----------|------|
| Weight | kg | Teal | ⚖️ Scale |
| Blood Pressure | mmHg | Red | 📈 Waveform |
| Heart Rate | bpm | Red | ❤️ Heart |
| Blood Glucose | mg/dL | Teal | 💧 Drop |
| Temperature | °C | Amber | 🌡️ Thermometer |
| SpO2 | % | Blue | 💨 Wind |
| Steps | steps | Green | 👟 Footsteps |
| Sleep | hrs | Purple | 🌙 Moon |
| Water Intake | glasses | Cyan | 💧 Water drop |
| BMI | — | Teal | 📊 Trend arrow |
| Cholesterol | mg/dL | Amber | 💧 Drop |
| Waist | cm | Blue | 📏 Ruler |
| Respiratory Rate | /min | Coral | 🫁 Lungs |

**FAB:** Teal + icon → opens "Add Measurement" bottom sheet

**Add Measurement Bottom Sheet:**
- Dropdown: Select metric type
- Value input (numeric keyboard)
- Optional notes field
- Date/time (defaults to now, can adjust)
- "Save" button

**Metric Detail Screen** (on card tap):
- Title: metric name
- Line chart showing history of this metric (fl_chart package)
- List of all entries for this metric (value, date, notes)
- Delete individual entries (swipe left)
- "Add Entry" button

**Normal Range Indicator:**
- Optional soft color coding (green in normal, amber slightly off, red out of range)
- Based on WHO/medical reference ranges
- Disclaimer: "These ranges are informational only. Consult your doctor."

---

### 13. HISTORY SCREEN 📊

**Header:** Dark gradient, "Medication History" title

**Top Section: Adherence Dashboard**
```
┌─────────────────────────────────────┐
│   Last 30 Days Adherence           │
│                                     │
│         [Large % circle]            │
│              87%                    │
│                                     │
│  ✅ Taken    ⏭️ Skipped  ❌ Missed  │
│  23 (72%)   4 (13%)    5 (15%)     │
│  [████████] [████     ] [█████    ] │
│                                     │
│  🔥 Current Streak: 5 days         │
│  💬 "Great job! Keep it up!"        │
└─────────────────────────────────────┘
```

**Encouragement Messages (based on adherence %):**
- 90%+: "🏆 Outstanding! You're a medicine hero!"
- 75-89%: "💪 Great job! Keep it up!"
- 50-74%: "👍 Good progress! You can do even better."
- Below 50%: "💙 Every dose counts. Let's get back on track."

**Filter Bar:**
- Date range: Today | Last 7 days | Last 30 days | All Time
- Status filter: All | Taken | Skipped | Missed
- Medicine filter (dropdown)

**Timeline List:**
Each entry card:
```
[Status icon]  [Medicine Name]     [Time badge]
               Scheduled: 08:00   ✅ Taken
               Actual: 08:03      +3 min
```

Status icon + color:
- ✅ Green — Taken on time (within 15 min)
- ⏰ Amber — Taken late (>15 min)
- ⏭️ Blue — Skipped
- ❌ Red — Missed

**Pull to refresh**, paginated loading

---

### 14. PROFILE SCREEN 👤

**Layout (scrollable):**

**Top Header:**
```
[Large avatar circle — initial or photo]
[Full Name]
[email]
[Role badge: Patient 💊 / Caregiver 🤝]
```

**Account Stats Grid (2x3):**
| Medicines | Reminders | Doses Taken |
| Adherence % | Day Streak 🔥 | Member Since |

**Premium Card (if not premium):**
```
┌─ ⭐ Upgrade to Premium ─────────────┐ (purple→pink gradient border)
│ • Unlimited medicines               │
│ • Cloud backup & sync               │
│ • Advanced analytics                │
│ • Priority support                  │
│ • Ad-free (future)                  │
│                                     │
│ [Upgrade Now — $4.99/year]         │
└─────────────────────────────────────┘
```

**Settings Sections:**

*Appearance*
- Dark Mode toggle (default: ON)
- [Future: accent color picker]

*Language*
- Opens bottom sheet with 4 flag options:
  🇦🇱 Shqip (Albanian) | 🇬🇧 English | 🇩🇪 Deutsch | 🇫🇷 Français
  Checkmark on selected

*Notifications*
- Enable/disable all notifications toggle
- Notification sound toggle
- Vibration toggle

*Privacy & Security*
- Share analytics toggle
- Crash reports toggle
- Biometric lock toggle (Face ID / Fingerprint) [V2]

*Data Management*
- **Export My Data** → generates JSON or PDF, shares via native share sheet
- **Firebase Sync** → manually trigger backup to Firebase
- **Clear All Data** → double confirmation (type "DELETE" to confirm) → full reset

*Caregiver Mode (only shown if user is Caregiver)*
- **Manage Patient Profile** → CaregiverDashboardScreen
- Patient name display

*About*
- ⚠️ Medical Disclaimer (expandable)
- Help & Support → email/contact
- Privacy Policy → WebView
- Terms of Service → WebView
- Rate MediFlow → app store link
- App Version: v2.0.0 (build 1)

**Logout Button** (bottom, danger outlined)
→ confirmation dialog → clear session → go to AuthStack

---

### 15. CAREGIVER DASHBOARD SCREEN

**Only visible to Caregiver role users**

**Layout:**
- Header: "My Patient" + patient name
- Patient's adherence summary (ring + %)
- Patient's today's schedule (view-only version)
- Patient's medicine list
- "Edit Patient's Medicines" button
- Adherence calendar (30 days, colored dots per day)
- "Generate Report" → exports PDF for doctor visit

**Note:** In V1, caregiver uses the same device/account. V2 would allow remote caregiver mode via Firebase sync between two devices.

---

### 16. DATA EXPORT SCREEN

**Options:**
- Format: JSON | PDF
- Include: Medicines ✓ | Reminders ✓ | History ✓ | Health Metrics ✓
- Date range: All | Last 30 days | Custom range
- "Generate & Share" button → creates file → native share sheet
- QR Code option (for quick share with doctor)

---

## 🏗️ TECHNICAL ARCHITECTURE

### Technology Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **Framework** | Flutter (Dart) | Cross-platform, premium UI, native performance |
| **State Management** | Riverpod 2.x | Type-safe, testable, excellent for Flutter |
| **Local Database** | sqflite + drift | SQLite ORM with type safety |
| **Cloud Backup** | Firebase Firestore + Auth | Free tier sufficient, reliable |
| **OCR** | Google ML Kit (`google_mlkit_text_recognition`) | Free, offline, on-device, no API key |
| **Barcode** | `mobile_scanner` | Free barcode/QR, both platforms |
| **Medicine API** | OpenFDA API | Free, official, no key needed |
| **Notifications** | `flutter_local_notifications` | Full local notifications iOS + Android |
| **Camera** | `camera` (Flutter official) | Full camera control |
| **Image Processing** | `image` package | Resize, grayscale, contrast |
| **Navigation** | GoRouter | Declarative, deep link ready |
| **i18n** | `flutter_localizations` + ARB files | Official Flutter i18n system |
| **Charts** | `fl_chart` | Beautiful, animated charts for Health |
| **PDF Generation** | `pdf` + `printing` | Generate reports for doctors |
| **Sharing** | `share_plus` | Cross-platform share sheet |
| **Secure Storage** | `flutter_secure_storage` | For auth tokens |
| **SharedPreferences** | `shared_preferences` | Simple settings/session |
| **Fonts** | `google_fonts` (Inter) | Clean modern typography |
| **Icons** | `lucide_icons` or Material | Consistent icon set |
| **Animations** | `flutter_animate` | Micro-animations, transitions |
| **Image Picker** | `image_picker` | Gallery import for scan |
| **Crypto** | `crypto` | SHA-256 password hashing |
| **Date Utils** | `intl` | Date formatting + l10n |

---

### Project Structure

```
mediflow/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # MaterialApp, theme, routing
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # Full color palette (dark + light)
│   │   │   ├── app_typography.dart  # TextStyles
│   │   │   ├── app_dimensions.dart  # Spacing, radius constants
│   │   │   └── app_strings.dart     # Non-localized strings (keys)
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # ThemeData dark + light
│   │   │   └── theme_provider.dart  # Riverpod theme state
│   │   │
│   │   ├── router/
│   │   │   └── app_router.dart      # GoRouter configuration
│   │   │
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       ├── validators.dart
│   │       └── extensions.dart
│   │
│   ├── l10n/
│   │   ├── app_en.arb              # English
│   │   ├── app_sq.arb              # Albanian
│   │   ├── app_de.arb              # German
│   │   └── app_fr.arb              # French
│   │
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart   # Drift database definition
│   │   │   ├── tables/
│   │   │   │   ├── users_table.dart
│   │   │   │   ├── medicines_table.dart
│   │   │   │   ├── reminders_table.dart
│   │   │   │   ├── history_table.dart
│   │   │   │   └── health_table.dart
│   │   │   └── daos/               # Data access objects
│   │   │       ├── medicines_dao.dart
│   │   │       ├── reminders_dao.dart
│   │   │       ├── history_dao.dart
│   │   │       └── health_dao.dart
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── medicine_model.dart
│   │   │   ├── reminder_model.dart
│   │   │   ├── history_entry_model.dart
│   │   │   └── health_measurement_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── medicine_repository.dart
│   │   │   ├── reminder_repository.dart
│   │   │   ├── history_repository.dart
│   │   │   └── health_repository.dart
│   │   │
│   │   └── services/
│   │       ├── ocr_service.dart           # ML Kit OCR + parsing
│   │       ├── barcode_service.dart       # Barcode scanning
│   │       ├── openfda_service.dart       # FDA API calls
│   │       ├── notification_service.dart  # Local notifications
│   │       ├── firebase_sync_service.dart # Firestore backup
│   │       ├── export_service.dart        # PDF/JSON export
│   │       └── auth_service.dart          # Auth + session
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart
│   │   │   └── screens/
│   │   │       ├── splash_screen.dart
│   │   │       ├── onboarding_screen.dart
│   │   │       ├── role_selection_screen.dart
│   │   │       ├── welcome_screen.dart
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── providers/
│   │   │   │   └── home_provider.dart
│   │   │   └── screens/
│   │   │       └── home_screen.dart
│   │   │
│   │   ├── medicines/
│   │   │   ├── providers/
│   │   │   │   └── medicine_provider.dart
│   │   │   └── screens/
│   │   │       ├── scan_screen.dart
│   │   │       ├── add_medicine_screen.dart
│   │   │       └── medicine_detail_screen.dart
│   │   │
│   │   ├── reminders/
│   │   │   ├── providers/
│   │   │   │   └── reminder_provider.dart
│   │   │   └── screens/
│   │   │       └── reminder_setup_screen.dart
│   │   │
│   │   ├── health/
│   │   │   ├── providers/
│   │   │   │   └── health_provider.dart
│   │   │   └── screens/
│   │   │       ├── health_screen.dart
│   │   │       └── health_detail_screen.dart
│   │   │
│   │   ├── history/
│   │   │   ├── providers/
│   │   │   │   └── history_provider.dart
│   │   │   └── screens/
│   │   │       └── history_screen.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── providers/
│   │   │   │   └── profile_provider.dart
│   │   │   └── screens/
│   │   │       ├── profile_screen.dart
│   │   │       ├── caregiver_dashboard_screen.dart
│   │   │       └── data_export_screen.dart
│   │   │
│   │   └── main_tab/
│   │       └── main_tab_screen.dart   # Bottom nav shell
│   │
│   └── shared/
│       └── widgets/
│           ├── app_button.dart        # Multi-variant button
│           ├── app_card.dart          # Base card component
│           ├── app_input.dart         # Text input with theming
│           ├── app_badge.dart         # Status badges/chips
│           ├── empty_state.dart       # Empty data placeholder
│           ├── loading_indicator.dart # Branded loader
│           ├── gradient_header.dart   # Reusable gradient header
│           ├── medicine_icon.dart     # Pill icon with color by form
│           ├── medical_disclaimer.dart # Disclaimer banner widget
│           ├── stats_card.dart        # Stats grid card
│           ├── adherence_ring.dart    # Circular adherence chart
│           └── snackbar_utils.dart    # Success/error snackbars
│
├── assets/
│   ├── images/
│   │   ├── logo.png
│   │   ├── logo_white.png
│   │   └── onboarding/
│   │       ├── onboarding_1.png
│   │       ├── onboarding_2.png
│   │       └── onboarding_3.png
│   └── animations/             # Lottie files (optional)
│
├── test/
├── android/
├── ios/
├── pubspec.yaml
├── .env                        # Firebase config (gitignored)
└── README.md
```

---

### Database Schema (Drift ORM)

```dart
// 5 Tables

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 2, max: 100)();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get role => text()(); // 'patient' | 'caregiver'
  BoolColumn get isPremium => boolean().withDefault(Constant(false))();
  TextColumn get language => text().withDefault(Constant('en'))();
  BoolColumn get isDarkMode => boolean().withDefault(Constant(true))();
  BoolColumn get notificationsEnabled => boolean().withDefault(Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get firebaseUid => text().nullable()();
}

class Medicines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get verifiedName => text()();
  TextColumn get brandName => text().nullable()();
  TextColumn get genericName => text().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get form => text().nullable()(); // tablet, capsule, etc.
  TextColumn get category => text().nullable()();
  IntColumn get quantity => integer().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get apiSource => text().withDefault(Constant('manual'))();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isActive => boolean().withDefault(Constant(true))();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get medicineId => integer().references(Medicines, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get time => text()(); // "08:00"
  TextColumn get frequency => text()(); // 'daily', 'specific_days', 'interval', 'as_needed'
  TextColumn get days => text().nullable()(); // JSON: ["Mon","Wed","Fri"]
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get durationType => text().withDefault(Constant('ongoing'))();
  DateTimeColumn get endDate => dateTime().nullable()();
  IntColumn get durationDays => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(Constant(true))();
  IntColumn get snoozeDuration => integer().withDefault(Constant(15))();
  IntColumn get notificationId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class HistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reminderId => integer().references(Reminders, #id)();
  IntColumn get medicineId => integer().references(Medicines, #id)();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get status => text()(); // 'taken', 'taken_late', 'skipped', 'missed'
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get actualTime => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

class HealthMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get type => text()(); // 'weight', 'blood_pressure', etc.
  RealColumn get value => real()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}
```

---

### Firebase Architecture

**Firebase Services Used:**
- Firebase Auth (email/password) — for cloud identity
- Cloud Firestore — backup of SQLite data (structured mirror)
- Firebase Storage — for medicine box photos (optional, V2)

**Sync Strategy:**
- Primary: SQLite (always works, offline)
- Firebase sync: on-demand (user triggers or on WiFi)
- Conflict resolution: Latest-write-wins (local takes priority)
- No real-time sync (V1) — manual backup only

**Firestore Structure:**
```
users/
  {firebaseUid}/
    profile: { name, email, role, isPremium }
    medicines/
      {medicineId}: { ...medicine data }
    reminders/
      {reminderId}: { ...reminder data }
    history/
      {entryId}: { ...history entry }
    health/
      {measurementId}: { ...measurement }
```

**Free Tier Limits (Firestore):**
- 1 GB storage — easily enough for text data
- 50K reads/day, 20K writes/day — fine for personal use
- No payment needed for V1 at Albanian scale

---

### Notification System

**Package:** `flutter_local_notifications`

**Android Setup:**
- Notification channel: "MediFlow Reminders"
- Importance: High (shows on lock screen)
- Full-screen intent for critical reminders

**iOS Setup:**
- Request permission on first reminder creation
- Badge count management

**Notification Payload:**
```dart
{
  'type': 'medicine_reminder',
  'reminderId': 123,
  'medicineId': 45,
  'medicineName': 'Paracetamol',
  'scheduledTime': '2026-02-19T08:00:00'
}
```

**Notification Actions (Android 8+):**
- ✅ Take — marks as taken without opening app
- ⏭️ Skip — marks as skipped without opening app
- ⏰ Snooze 15min — reschedules

**Tap behavior:** Opens MedicineDetailScreen for that medicine

---

### OCR & Medicine Scanning Details

**ML Kit Text Recognition:**
```dart
// No API key needed, runs on-device
final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
final recognizedText = await textRecognizer.processImage(inputImage);
```

**Parsing Logic (`ocr_service.dart`):**
```dart
class OCRParser {
  // Extract medicine name: first prominent text block, likely the brand name
  // Usually the largest font size in the first 1/3 of detected blocks
  
  // Extract strength: regex patterns
  // Pattern 1: (\d+(?:\.\d+)?)\s*(mg|g|ml|mcg|µg|IU|%|units)
  // Pattern 2: (\d+)\s*\/\s*(\d+)\s*(mg|ml) for combination drugs
  
  // Extract form: keyword matching against list
  // ['tablet', 'capsule', 'syrup', 'suspension', 'injection', 
  //  'cream', 'ointment', 'drops', 'inhaler', 'patch', 'spray']
  
  // Extract manufacturer: text after trigger keywords
  // ['manufactured by', 'marketed by', 'distributed by', 
  //  'product of', 'made by', 'mfg by']
  
  // Extract expiry: date patterns
  // ['EXP', 'Expiry', 'Expiration', 'Best before', 'BB']
  // Followed by: MM/YYYY, MM-YYYY, YYYY-MM, Month YYYY
  
  // Extract quantity: number before unit keywords
  // ['tablets', 'capsules', 'ml', 'pieces', 'units']
}
```

**OpenFDA Query (enrichment, when online):**
```
GET https://api.fda.gov/drug/label.json?
    search=openfda.brand_name:"${name}"
    &limit=3
```

Falls back to generic name search if brand not found.
Extracts: brand_name, generic_name, manufacturer_name, route, substance_name, product_type.

---

## 🌍 INTERNATIONALIZATION

**System:** Flutter ARB files + `flutter_localizations`

**Languages:**
| Code | Language | Flag |
|------|---------|------|
| `sq` | Shqip (Albanian) | 🇦🇱 |
| `en` | English | 🇬🇧 |
| `de` | Deutsch (German) | 🇩🇪 |
| `fr` | Français (French) | 🇫🇷 |

**Default:** English (fallback for missing translations)
**First Launch Default:** Albanian (since Albania-first market)
**Persisted:** User's language choice saved in SQLite + SharedPreferences

**Key translation categories:**
- Auth: login, register, validation messages
- Home: greetings, stats labels, section headers
- Medicines: all field labels, form types, empty states
- Reminders: frequency options, time presets, notifications text
- Health: metric names, units, status messages
- History: status labels, adherence messages, filters
- Profile: settings labels, sections, about text
- Common: buttons (Save, Cancel, Delete, Confirm), errors, success messages
- Medical Disclaimer: must be translated accurately

---

## 💰 MONETIZATION

**Model:** Annual subscription ($4.99/year)

**Free Features (no subscription):**
- Track up to 10 medicines
- All reminder features
- Health dashboard (all 13 metrics)
- History & adherence tracking
- OCR scanning (unlimited scans)
- 4 languages
- Data export (JSON)

**Premium Features ($4.99/year):**
- Unlimited medicines
- Cloud backup & sync (Firebase)
- Advanced analytics & trends
- PDF report generation (doctor export)
- Priority support
- Caregiver advanced features (future)

**Payment Processing:** RevenueCat (handles Apple + Google subscriptions, free up to $2.5K monthly revenue, then 1%)

**Special Offers:**
- Launch discount: 50% off first year
- Seasonal promotions (New Year health goals, etc.)
- Referral discounts (V2)

---

## 🔐 SECURITY

- Passwords: SHA-256 hashed before storage (never plain text)
- Firebase tokens: stored in `flutter_secure_storage` (iOS Keychain / Android Keystore)
- No personal health data sent to any analytics service
- Firebase Firestore security rules: users can only read/write their own data
- Medicine data: local-first, cloud is optional backup only
- No ads, no data selling
- GDPR-friendly architecture (data export + delete all)

---

## ✅ FEATURE CHECKLIST (Build Priority)

### Phase 1 — MVP (Core Features)
- [ ] Splash + Onboarding + Role Selection
- [ ] Auth (Register + Login)
- [ ] Home Screen with stats
- [ ] Add Medicine (manual)
- [ ] Medicine Detail + Edit + Delete
- [ ] Reminder Setup + local notifications
- [ ] Mark as Taken / Skipped
- [ ] History timeline
- [ ] Profile + Settings
- [ ] Dark/Light theme toggle
- [ ] 4 Language support
- [ ] SQLite database

### Phase 2 — Smart Features
- [ ] OCR Scan (ML Kit)
- [ ] Barcode scan
- [ ] OpenFDA API enrichment
- [ ] Health Dashboard (all 13 metrics)
- [ ] Health detail charts
- [ ] Adherence analytics
- [ ] Firebase Auth + Firestore backup
- [ ] Data export (JSON + PDF)
- [ ] Caregiver Dashboard

### Phase 3 — Premium & Polish
- [ ] Premium subscription (RevenueCat)
- [ ] Push notification actions (take/skip from notification)
- [ ] Notification snooze
- [ ] Advanced analytics & trends
- [ ] App onboarding improvements
- [ ] App store optimization
- [ ] Performance optimization
- [ ] Automated tests

---

## 📋 KEY DEPENDENCIES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.7

  # Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: ^1.9.0

  # Firebase
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.1.0

  # OCR & Camera
  google_mlkit_text_recognition: ^0.13.1
  camera: ^0.11.0
  image: ^4.2.0
  image_picker: ^1.1.2
  mobile_scanner: ^5.2.3

  # Notifications
  flutter_local_notifications: ^17.2.2

  # UI & Design
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  fl_chart: ^0.68.0
  lottie: ^3.1.2  # optional animations

  # Auth & Security
  crypto: ^3.0.3
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.1

  # Export
  pdf: ^3.11.0
  printing: ^5.13.1
  share_plus: ^10.0.0

  # Utils
  intl: ^0.19.0
  http: ^1.2.1

  # Monetization
  purchases_flutter: ^7.2.0  # RevenueCat

dev_dependencies:
  flutter_test:
    sdk: flutter
  drift_dev: ^2.18.0
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.0
  flutter_gen_runner: ^5.6.0
```

---

## ⚠️ IMPORTANT NOTES FOR CURSOR / OPENCODE

1. **Start with the design system** — Set up `app_colors.dart`, `app_theme.dart`, and `app_typography.dart` before building any screen. All colors must come from constants, never hardcoded.

2. **Database first** — Set up Drift schema and DAOs before screens. Every screen must go through repositories.

3. **Riverpod everywhere** — No setState() for app state. Only use StatefulWidget for purely local UI state (animation, text field focus).

4. **Dark mode by default** — The app opens in dark mode. Light mode is a toggle. Both must look premium.

5. **Every screen must be scrollable** — Use SingleChildScrollView or CustomScrollView. Never let content overflow on smaller devices.

6. **Always show the Medical Disclaimer** — It must appear on: Add Medicine screen, Medicine Detail screen, Profile screen. Non-negotiable.

7. **OCR requires AndroidManifest permissions** — Camera permission, storage permission must be configured.

8. **ML Kit offline** — `google_mlkit_text_recognition` works 100% offline. No API key needed. This is the scanner.

9. **Notification permissions** — Must request at the right time (on first reminder creation, not at app launch).

10. **Firebase is backup only** — App must work perfectly without Firebase. Firebase is additive.

11. **i18n from day one** — Never hardcode user-facing strings. Always use `AppLocalizations.of(context)`.

12. **Caregiver = same app** — Do not create two separate apps. Role-based feature visibility using Riverpod state.

13. **SQLite date as epoch** — Store all dates as DateTime, let Drift handle serialization.

14. **Password hash** — Use `crypto` package, SHA-256: `sha256.convert(utf8.encode(password)).toString()`

15. **History auto-generation** — When a reminder time passes and user hasn't marked it, the system should auto-mark as "missed" (run check on app resume and at midnight).
```
