# MediFlow — UI Redesign: Surgical Antigravity Prompts
**Version:** 1.0 | **Author:** Claude | **Date:** February 21, 2026  
**Purpose:** Paste each prompt INTO Antigravity one at a time. Never skip verification. Never combine prompts.

---

## ⚠️ MASTER RULES — READ BEFORE STARTING

1. **One prompt at a time.** Do not paste two prompts together. Wait for verification to pass before moving to the next.
2. **After every prompt:** Run `flutter run -d ZT322VL7FR` (full restart — not hot reload). Take a screenshot. Compare visually.
3. **If Antigravity says "done" but the screen looks the same:** The agent lied. Paste the verification check (at the bottom of each prompt) and demand it show the actual diff.
4. **Never accept "done" without running the app.** The screenshots are the only truth.
5. **Do NOT change:** Any provider, repository, DAO, router file, database schema, or localization file. Design only.
6. **Exact hex codes must be used.** "Teal" or "cyan" are not acceptable — use `Color(0xFF00E5FF)` explicitly.

---

## 📋 PROMPT ORDER

| # | Target | What Changes |
|---|--------|--------------|
| 1 | `lib/core/widgets/adherence_ring.dart` | True neon ring with glow + animation |
| 2 | `lib/core/widgets/glass_card.dart` + `neon_card.dart` | Proper glassmorphism cards |
| 3 | `lib/features/main_tab/main_tab_screen.dart` | Bottom nav with cyan dot indicator |
| 4 | `lib/features/home/screens/home_screen.dart` | Full home redesign |
| 5 | `lib/features/health/screens/health_screen.dart` | Health dashboard upgrade |
| 6 | `lib/features/history/screens/history_screen.dart` | History screen upgrade |
| 7 | `lib/features/profile/screens/profile_screen.dart` | Profile/settings upgrade |
| 8 | `lib/features/medicines/screens/add_medicine_screen.dart` | Add medicine form upgrade |
| 9 | `lib/features/auth/screens/welcome_screen.dart` | Welcome/auth screens upgrade |
| 10 | `lib/features/medicines/screens/medicine_detail_screen.dart` | Medicine detail upgrade |

---

---

# PROMPT 1 — Adherence Ring Widget

> **File:** `lib/core/widgets/adherence_ring.dart`  
> **Do NOT touch:** Any other file. Only this one widget.

```
Open ONLY the file: lib/core/widgets/adherence_ring.dart

Completely replace its contents with the following. Do not change any other file.
This widget must be a CustomPainter-based animated ring with a neon glow effect.

Requirements:
- Size: configurable via `size` param (default 160.0)
- Stroke width: 14px
- Background track color: Color(0xFF1A2D45)
- Progress arc: gradient from Color(0xFF00E5FF) to Color(0xFF0066FF)
- Center: shows percentage as bold white 40sp text + "adherence" label in Color(0xFF3D8FA8) at 13sp
- Outer glow: achieved with BoxDecoration boxShadow using Color(0x3300E5FF) at blurRadius 40
- Animation: AnimationController that goes from 0.0 to the actual percentage value over 800ms using Curves.easeInOut when the widget first mounts
- The widget accepts: double percentage (0.0 to 100.0), double size (optional, default 160.0)

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot of the Home screen and confirm you can see a ring shape (not a filled circle) with a cyan arc that glows.
```

**✅ Verification:** The adherence ring must show as an ARC (like a donut/ring), NOT a filled circle. The center must be transparent showing the background. There must be a visible glow radiating outward from the ring in cyan.

---

---

# PROMPT 2 — Core Card Widgets

> **Files:** `lib/core/widgets/glass_card.dart` AND `lib/core/widgets/neon_card.dart`  
> **Do NOT touch:** Any screen files. Only these two widget files.

```
Open the files: 
- lib/core/widgets/glass_card.dart
- lib/core/widgets/neon_card.dart

For glass_card.dart — replace with a GlassCard widget that has:
- Background color: Color(0x0DFFFFFF) — 5% white for glassmorphism
- Border: 1px solid Color(0x1AFFFFFF) — 10% white border
- BorderRadius: 16px
- Optional boxShadow (default none)
- Padding: configurable, default EdgeInsets.all(16)
- child: Widget (required)

For neon_card.dart — replace with a NeonCard widget that has:
- Background color: Color(0xFF0D1826)
- Border: 1px solid Color(0x1A00E5FF) — 10% cyan border  
- BorderRadius: 16px
- BoxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0,4))]
- Padding: configurable, default EdgeInsets.all(16)
- child: Widget (required)

Both widgets must be simple stateless widgets with a Container as root.

Do not change any screen files. Do not change app_colors.dart.
After saving, run: flutter run -d ZT322VL7FR
Confirm the app still compiles and runs without errors.
```

**✅ Verification:** App must compile clean. No visual changes needed yet — this is prep work.

---

---

# PROMPT 3 — Bottom Navigation Bar

> **File:** `lib/features/main_tab/main_tab_screen.dart`  
> **Do NOT touch:** Tab logic, index providers, routes, or any other file.

```
Open ONLY the file: lib/features/main_tab/main_tab_screen.dart

Find the BottomNavigationBar or NavigationBar widget in this file.
Replace ONLY the decoration/style of the bottom navigation — do not change tab logic, providers, or navigation behavior.

The bottom nav must now have:
1. Container wrapping the nav with:
   - Background: Color(0xFF0A1628)
   - Top border only: Border(top: BorderSide(color: Color(0x1A00E5FF), width: 1))
   - No elevation

2. Each nav item icon+label behavior:
   - Selected icon color: Color(0xFF00E5FF)
   - Selected label color: Color(0xFF00E5FF)  
   - Unselected icon color: Color(0xFF3D5068)
   - Unselected label color: Color(0xFF3D5068)

3. Below each SELECTED nav icon, add a small 4px wide, 4px tall, rounded cyan dot:
   - Color: Color(0xFF00E5FF)
   - BorderRadius: BorderRadius.circular(2)
   - Only visible when that tab is selected
   - Positioned centered below the icon

4. Nav item icons to use (with label):
   - Tab 0: Icons.home_rounded / "Home"
   - Tab 1: Icons.favorite_rounded / "Health"  
   - Tab 2: Icons.history_rounded / "History"
   - Tab 3: Icons.person_rounded / "Profile"

Use a custom bottom navigation built with Row + GestureDetector + Column widgets if needed to achieve the dot indicator. The standard BottomNavigationBar does not support the dot indicator natively.

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot. Confirm the bottom nav is darker, has a cyan top border line, and shows a small cyan dot below the active tab icon.
```

**✅ Verification:** Bottom nav background must be noticeably darker than before. The active tab must show a small cyan dot beneath its icon. Inactive tabs must have grey/muted icons.

---

---

# PROMPT 4 — Home Screen (MOST IMPORTANT)

> **File:** `lib/features/home/screens/home_screen.dart`  
> **Do NOT touch:** Providers, FAB navigation logic, GoRouter calls, medicine data loading, or any other file.

```
Open ONLY the file: lib/features/home/screens/home_screen.dart

This is a VISUAL redesign only. Do NOT change:
- Any ref.watch() providers
- Any context.push() or context.go() navigation
- Any database/data logic
- The FAB open/close state logic
- The greeting string logic
- Any import that deals with data

ONLY change the visual layer (Container decorations, colors, padding, Text styles, widget wrapping).

Apply these changes:

═══════════════════════════════════════════════════
1. BACKGROUND (Scaffold background)
═══════════════════════════════════════════════════
The Scaffold background must use a Stack with:
- Layer 1 (bottom): Container with decoration BoxDecoration(gradient: RadialGradient(center: Alignment(0, -0.6), radius: 1.4, colors: [Color(0xFF0D1F35), Color(0xFF070B12)]))
- Layer 2: A CustomPaint widget that draws 15 tiny white dots scattered across the screen at fixed positions with opacity 0.04 (star particle effect). Each dot should be radius 1.2 to 2.0.

═══════════════════════════════════════════════════
2. HEADER SECTION
═══════════════════════════════════════════════════
The greeting text: fontSize 14, color Color(0xFF8A9BB5)
The name text: fontSize 28, fontWeight FontWeight.w700, color Color(0xFFFFFFFF)

The avatar circle (top right):
- Size: 48x48
- Decoration: BoxDecoration with gradient LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0066FF)]), shape BoxShape.circle
- BoxShadow: [BoxShadow(color: Color(0x4D00E5FF), blurRadius: 20, offset: Offset(0, 4))]
- Initial letter: fontSize 20, fontWeight w700, color Color(0xFF070B12)

═══════════════════════════════════════════════════
3. STATS ROW (3 chips: Medicines, Today, Reminders)
═══════════════════════════════════════════════════
Each chip must be an Expanded Container with:
- decoration: BoxDecoration(color: Color(0x0DFFFFFF), border: Border.all(color: Color(0x1AFFFFFF), width: 1), borderRadius: BorderRadius.circular(14))
- padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8)
- Inside: Column with:
  * Icon (the relevant icon) at size 20, color Color(0xFF00E5FF)
  * SizedBox(height: 4)
  * Text (the value) fontSize 22, fontWeight w700, color Color(0xFF00E5FF)
  * Text (the label) fontSize 11, color Color(0xFF8A9BB5)

═══════════════════════════════════════════════════
4. ADHERENCE RING (hero element)
═══════════════════════════════════════════════════
Center the AdherenceRing widget on screen with size 160.0.
Wrap it in a Container with:
- BoxDecoration boxShadow: [BoxShadow(color: Color(0x2200E5FF), blurRadius: 50, spreadRadius: 10)]
This creates the outer luminous glow around the entire ring.

Below the ring, the motivational text label:
- fontSize 13, color Color(0xFF8A9BB5), centered

═══════════════════════════════════════════════════
5. SECTION HEADERS
═══════════════════════════════════════════════════
Every section header ("Today's Schedule", "My Medicines", etc.) must use this pattern:
Row(children: [
  Container(width: 3, height: 18, decoration: BoxDecoration(color: Color(0xFF00E5FF), borderRadius: BorderRadius.circular(2))),
  SizedBox(width: 8),
  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF00E5FF))),
])
Remove any emoji from section headers. The left cyan bar is the visual accent instead.

═══════════════════════════════════════════════════
6. TODAY'S SCHEDULE CARDS (when medicines are scheduled)
═══════════════════════════════════════════════════
Each schedule card must be:
Container(
  decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0,4))]),
  child: Row(children: [
    // Left status bar: 3px wide full-height colored bar
    Container(width: 3, decoration: BoxDecoration(color: [pendingColor/takenColor/missedColor], borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
    SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(medicineName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(scheduledTime, style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
    ])),
    // Status badge pill
    Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), border: Border.all(color: statusColor), borderRadius: BorderRadius.circular(20)), child: Text(statusText, style: TextStyle(fontSize: 12, color: statusColor))),
    SizedBox(width: 8),
  ]),
)
Status colors: pending = Color(0xFFFFB800), taken = Color(0xFF00E5FF), missed = Color(0xFFFF3B5C)

═══════════════════════════════════════════════════
7. MEDICINE CARDS in "My Medicines"
═══════════════════════════════════════════════════
Each medicine card row:
Container(
  margin: EdgeInsets.only(bottom: 8),
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0,4))]),
  child: Row(children: [
    // Form type icon square
    Container(
      width: 48, height: 48,
      decoration: BoxDecoration(color: Color(0xFF0D2840), borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(formEmoji, style: TextStyle(fontSize: 24))),
    ),
    SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      Text(formType, style: TextStyle(fontSize: 13, color: Color(0xFF3D6080))),
    ])),
    Text(strength, style: TextStyle(fontSize: 14, color: Color(0xFF00E5FF))),
    SizedBox(width: 4),
    Icon(Icons.chevron_right, color: Color(0xFF3D6080), size: 16),
  ]),
)
Form emoji map: Tablet = 💊, Capsule = 💊, Liquid = 🧪, Injection = 💉, Other = 🩺

═══════════════════════════════════════════════════
8. HEALTH TIP CARD
═══════════════════════════════════════════════════
The health tip card:
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF00C896), Color(0xFF00E5FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: Color(0x3300C896), blurRadius: 20, offset: Offset(0,4))],
  ),
  child: Row(children: [
    Text('💊', style: TextStyle(fontSize: 28)),
    SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Health Tip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      SizedBox(height: 2),
      Text(tipText, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9))),
    ])),
    Text('✨', style: TextStyle(fontSize: 20)),
  ]),
)

═══════════════════════════════════════════════════
9. FAB BUTTON
═══════════════════════════════════════════════════
Main FAB button:
Container(
  width: 56, height: 56,
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0066FF)]),
    shape: BoxShape.circle,
    boxShadow: [BoxShadow(color: Color(0x6600E5FF), blurRadius: 20, offset: Offset(0,4))],
  ),
  child: AnimatedRotation(turns: _fabOpen ? 0.125 : 0, duration: Duration(milliseconds: 200), child: Icon(Icons.add_rounded, color: Color(0xFF070B12), size: 32)),
)

Mini FAB labels:
Container(
  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x4000E5FF)), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color(0x2200E5FF), blurRadius: 8)]),
  child: Text(label, style: TextStyle(fontSize: 14, color: Colors.white)),
)

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot of the Home screen. Confirm you can see:
✓ Dark radial gradient background (not flat black)
✓ Star/particle dots visible (subtle)
✓ Adherence ring is a RING shape (donut) with glow
✓ Stats row chips are glassmorphism (slightly lighter than background)
✓ Section headers have a left cyan bar + cyan text
✓ Medicine cards have the dark card style with cyan border glow
✓ Health tip card has the green-to-cyan gradient
✓ FAB has gradient button with strong glow
```

**✅ Verification:** Compare screenshot to reference image. The home screen must no longer look flat — it must have visible depth through gradient background, glowing ring, and neon-bordered cards.

---

---

# PROMPT 5 — Health Dashboard Screen

> **File:** `lib/features/health/screens/health_screen.dart`  
> **Do NOT touch:** Providers, metric data loading, add measurement logic, grid/list toggle state, or any other file.

```
Open ONLY the file: lib/features/health/screens/health_screen.dart

VISUAL REDESIGN ONLY. Do NOT change data providers, state, or logic.

Apply these changes:

1. BACKGROUND: Same radial gradient as home screen:
   Container with RadialGradient(center: Alignment(0, -0.6), radius: 1.4, colors: [Color(0xFF0D1F35), Color(0xFF070B12)])

2. APP BAR / HEADER:
   Remove any solid-colored AppBar. Use a transparent/gradient header:
   - Title "Health Dashboard" fontSize 24, fontWeight w700, color Colors.white
   - Subtitle "Track your vital signs" fontSize 13, color Color(0xFF8A9BB5)
   - Grid/List toggle: Two icons in a NeonCard container (width 90px, height 38px), selected = Color(0xFF00E5FF) icon, unselected = Color(0xFF3D5068)

3. GRID METRIC CARDS:
   Each card in grid mode:
   Container(
     padding: EdgeInsets.all(14),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0,4))]),
     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
         Text(metricIcon, style: TextStyle(fontSize: 24)),  // emoji icon
         if (hasData) Container(width: 8, height: 8, decoration: BoxDecoration(color: Color(0xFF00E5FF), shape: BoxShape.circle)),  // cyan dot if data exists
       ]),
       SizedBox(height: 6),
       Container(height: 2, width: 28, color: metricAccentColor),  // colored accent line
       SizedBox(height: 8),
       Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
       Text(unit, style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
       SizedBox(height: 2),
       Text(metricName, style: TextStyle(fontSize: 13, color: Colors.white)),
     ]),
   )

   If no data for a metric, show "—" in Color(0xFF2A4060) for the value, NOT blank.

   Accent colors per metric type:
   - Weight: Color(0xFF00E5FF) cyan
   - Blood Pressure: Color(0xFFFF4D6A) red  
   - Heart Rate: Color(0xFFFF4D6A) red
   - Blood Glucose: Color(0xFF00C896) green
   - Temperature: Color(0xFFFFB800) amber
   - SpO2: Color(0xFF6B7FCC) indigo
   - Steps: Color(0xFF00C896) green
   - Sleep: Color(0xFF8B5CF6) purple
   - Other metrics: Color(0xFF00E5FF) cyan

4. LIST METRIC CARDS:
   Each row in list mode:
   Container(
     margin: EdgeInsets.only(bottom: 10),
     padding: EdgeInsets.all(14),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 16, offset: Offset(0,4))]),
     child: Row(children: [
       Container(width: 44, height: 44, decoration: BoxDecoration(color: Color(0xFF0D2840), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(emoji, style: TextStyle(fontSize: 22)))),
       SizedBox(width: 12),
       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text(metricName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
         Text(lastUpdatedDate, style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
       ])),
       Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
         Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
         Text(unit, style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
       ]),
     ]),
   )

5. FAB BUTTON (Add Measurement):
   Same gradient style as home FAB:
   decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0066FF)]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x6600E5FF), blurRadius: 20)])

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot of the Health screen. Confirm:
✓ Dark gradient background (not flat)
✓ Grid cards show metric icon, colored accent line, and bold value prominently
✓ Empty metrics show "—" not blank
✓ Cards have visible cyan border glow
```

---

---

# PROMPT 6 — History Screen

> **File:** `lib/features/history/screens/history_screen.dart`  
> **Do NOT touch:** Providers, filter logic, date range logic, or any other file.

```
Open ONLY the file: lib/features/history/screens/history_screen.dart

VISUAL REDESIGN ONLY. Do NOT change filter logic, date range logic, or data providers.

Apply these changes:

1. BACKGROUND: Same radial gradient background as other screens.

2. HERO ADHERENCE RING:
   Use AdherenceRing widget with size: 180.0 (larger than home screen).
   Wrap in Container with BoxShadow(color: Color(0x2200E5FF), blurRadius: 60, spreadRadius: 15) for stronger outer glow.
   Add label below: "Last 30 Days" in fontSize 12, color Color(0xFF8A9BB5)

3. STAT CHIPS ROW (Taken, Skipped, Missed):
   Each chip:
   Container(
     padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
     decoration: BoxDecoration(
       color: [takenColor/skippedColor/missedColor].withOpacity(0.08),
       border: Border.all(color: [takenColor/skippedColor/missedColor].withOpacity(0.3)),
       borderRadius: BorderRadius.circular(14),
     ),
     child: Column(children: [
       Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: statusColor)),
       Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
     ]),
   )
   Colors: taken = Color(0xFF00E5FF), skipped = Color(0xFF6B7FCC), missed = Color(0xFFFF3B5C)

4. FILTER CHIPS (Today / 7 Days / 30 Days / All Time  and  All / Taken / Skipped / Missed):
   Each chip:
   - Selected: Container with color Color(0xFF00E5FF), text color Color(0xFF070B12), borderRadius 20px
   - Unselected: Container with border Border.all(color: Color(0xFF2A3A4A)), text color Color(0xFF8A9BB5), borderRadius 20px
   - Animated switch between selected/unselected using AnimatedContainer

5. HISTORY ITEM CARDS:
   Each dose history item card:
   Container(
     margin: EdgeInsets.only(bottom: 8),
     padding: EdgeInsets.all(14),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(16)),
     child: Row(children: [
       // Status icon
       Container(width: 36, height: 36, decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(statusEmoji, style: TextStyle(fontSize: 18)))),
       SizedBox(width: 12),
       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text(medicineName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
         Text('Scheduled: $scheduledTime', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5))),
       ])),
       Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
         Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), border: Border.all(color: statusColor), borderRadius: BorderRadius.circular(12)), child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor))),
         SizedBox(height: 4),
         Text(actualTime, style: TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
       ]),
     ]),
   )
   Status emoji: ✅ taken, ⏭️ skipped, ❌ missed
   Status colors: taken = Color(0xFF00E5FF), skipped = Color(0xFF6B7FCC), missed = Color(0xFFFF3B5C)

6. EMPTY STATE:
   Center column:
   - 64px emoji: 💊 with Container behind it: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x2200E5FF), blurRadius: 40, spreadRadius: 20)])
   - Text "No history yet" fontSize 18, fontWeight w700, color Colors.white
   - Text subtitle fontSize 14, color Color(0xFF8A9BB5)

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot of the History screen. Confirm:
✓ Hero ring is larger than home screen ring
✓ Stat chips have tinted backgrounds matching their status color
✓ Filter chips clearly show selected vs unselected state
✓ Empty state has glowing emoji
```

---

---

# PROMPT 7 — Profile Screen

> **File:** `lib/features/profile/screens/profile_screen.dart`  
> **Do NOT touch:** Settings logic, language selector logic, dark mode toggle logic, navigation logic, or any other file.

```
Open ONLY the file: lib/features/profile/screens/profile_screen.dart

VISUAL REDESIGN ONLY. Do not change any setting handler functions, toggle logic, language switching, or navigation.

Apply these changes:

1. BACKGROUND: Same radial gradient background.

2. AVATAR HEADER:
   Avatar circle:
   - Size: 84x84
   - decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0066FF)]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Color(0x5500E5FF), blurRadius: 30, offset: Offset(0,4))])
   - Initial letter: fontSize 32, fontWeight w700, color Color(0xFF070B12)
   
   Below avatar:
   - Name: fontSize 22, fontWeight w700, color Colors.white
   - Email: fontSize 13, color Color(0xFF8A9BB5)
   - Role badge: Container(padding: symmetric(h:14, v:6), decoration: BoxDecoration(color: Color(0x1A00E5FF), border: Border.all(color: Color(0xFF00E5FF)), borderRadius: BorderRadius.circular(20)), child: Text('💊 Patient', style: TextStyle(fontSize: 13, color: Color(0xFF00E5FF))))

3. STATS GRID (6 stats: Medicines, Reminders, Doses Taken, Adherence, Streak, Member Since):
   2x3 grid of cards. Each card:
   Container(
     padding: EdgeInsets.all(12),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(14)),
     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text(statValue, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00E5FF))),
       SizedBox(height: 2),
       Text(statLabel, style: TextStyle(fontSize: 11, color: Color(0xFF8A9BB5))),
     ]),
   )

4. SECTION HEADERS in settings:
   Same pattern as home screen — 3px left cyan bar + cyan text:
   Row(children: [Container(width: 3, height: 16, color: Color(0xFF00E5FF)), SizedBox(width: 8), Text(sectionName, style: TextStyle(fontSize: 12, color: Color(0xFF8A9BB5), letterSpacing: 0.8, fontWeight: FontWeight.w600))])

5. SETTINGS ROWS:
   Each settings row:
   Container(
     margin: EdgeInsets.only(bottom: 1),
     decoration: BoxDecoration(color: Color(0xFF0D1826), borderRadius: BorderRadius.circular(14), border: Border.all(color: Color(0x1A00E5FF))),
     child: ListTile(
       leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
       title: Text(label, style: TextStyle(fontSize: 15, color: Colors.white)),
       trailing: [switch/chevron/value text],
       contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
     ),
   )

   Icon background colors (rounded colored squares):
   - Language: Color(0x1A6B7FCC) background, Color(0xFF6B7FCC) icon
   - Dark Mode: Color(0x1A00E5FF) background, Color(0xFF00E5FF) icon
   - Notifications: Color(0x1AFFB800) background, Color(0xFFFFB800) icon
   - Export Data: Color(0x1A00C896) background, Color(0xFF00C896) icon
   - Cloud Backup: Color(0x1A8B5CF6) background, Color(0xFF8B5CF6) icon
   - My Role: Color(0x1A00E5FF) background, Color(0xFF00E5FF) icon
   - About: Color(0x1A8A9BB5) background, Color(0xFF8A9BB5) icon
   - Log Out: Color(0x1AFF3B5C) background, Color(0xFFFF3B5C) icon, title color Color(0xFFFF3B5C)

   Toggles (Dark Mode, Notifications): Use Switch.adaptive with activeColor Color(0xFF00E5FF), activeTrackColor Color(0x5500E5FF)

6. PREMIUM CARD:
   Container(
     padding: EdgeInsets.all(18),
     decoration: BoxDecoration(
       gradient: LinearGradient(colors: [Color(0xFF1A0A2E), Color(0xFF2D1254)], begin: Alignment.topLeft, end: Alignment.bottomRight),
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: Color(0xFF7C3AED).withOpacity(0.5), width: 1.5),
       boxShadow: [BoxShadow(color: Color(0x338B5CF6), blurRadius: 20, offset: Offset(0,4))],
     ),
     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(children: [Text('⭐', style: TextStyle(fontSize: 20)), SizedBox(width: 8), Text('Upgrade to Premium', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))]),
       SizedBox(height: 10),
       // Benefit rows with checkmark
       ...benefits.map((b) => Padding(padding: EdgeInsets.only(bottom: 4), child: Row(children: [Icon(Icons.check_circle_rounded, color: Color(0xFF8B5CF6), size: 16), SizedBox(width: 8), Text(b, style: TextStyle(fontSize: 13, color: Color(0xFFD4AEFF)))]))),
       SizedBox(height: 14),
       Container(width: double.infinity, padding: EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('Upgrade Now — \$4.99/year', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)))),
     ]),
   )

After saving, run: flutter run -d ZT322VL7FR
Take a screenshot of the Profile screen. Confirm:
✓ Avatar has strong cyan gradient glow
✓ Stats grid cards have cyan number values
✓ Settings rows have colored icon squares (not plain icons)
✓ Premium card has purple gradient and border
✓ Log Out row has red icon and text
```

---

---

# PROMPT 8 — Add Medicine Screen

> **File:** `lib/features/medicines/screens/add_medicine_screen.dart`  
> **Do NOT touch:** Form validation, submit logic, reminder logic, date picker logic, or any other file.

```
Open ONLY the file: lib/features/medicines/screens/add_medicine_screen.dart

VISUAL REDESIGN ONLY. Do not change form state, validation, or submission logic.

Apply these changes:

1. BACKGROUND: Same radial gradient background.

2. APP BAR: 
   Replace any solid-color AppBar with a transparent AppBar:
   AppBar(
     backgroundColor: Colors.transparent,
     elevation: 0,
     leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF00E5FF)), onPressed: () => context.pop()),
     title: Text('Add Medicine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
     centerTitle: false,
   )

3. SECTION HEADERS inside form:
   Same pattern — 3px left cyan bar + cyan text.

4. INPUT FIELDS:
   All TextFormField decorations:
   InputDecoration(
     filled: true,
     fillColor: Color(0xFF111927),
     hintStyle: TextStyle(color: Color(0xFF4A5A72)),
     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF1A2840))),
     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF1A2840))),
     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFF00E5FF), width: 1.5)),
     errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Color(0xFFFF3B5C))),
     contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
   )

5. FORM TYPE CHIPS (Tablet, Capsule, Liquid, Injection):
   Each chip when UNSELECTED:
   Container(padding: symmetric(h:16, v:8), decoration: BoxDecoration(color: Color(0xFF111927), border: Border.all(color: Color(0xFF1A2840)), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: Color(0xFF8A9BB5))))

   Each chip when SELECTED:
   Container(padding: symmetric(h:16, v:8), decoration: BoxDecoration(color: Color(0xFF00E5FF).withOpacity(0.12), border: Border.all(color: Color(0xFF00E5FF)), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color(0x4000E5FF), blurRadius: 12)]), child: Text(label, style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w600)))

6. SUBMIT BUTTON ("Add Medicine" / "Next"):
   Container(
     width: double.infinity, height: 56,
     decoration: BoxDecoration(
       gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0066FF)]),
       borderRadius: BorderRadius.circular(100),
       boxShadow: [BoxShadow(color: Color(0x6600E5FF), blurRadius: 20, offset: Offset(0,6))],
     ),
     child: Center(child: Text('Add Medicine', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF070B12)))),
   )

7. REMINDER TIME CHIPS:
   Same style as form type chips above (selected/unselected pattern).

After saving, run: flutter run -d ZT322VL7FR
Navigate to Add Medicine screen. Take a screenshot. Confirm:
✓ AppBar is transparent (no flat teal header)
✓ Input fields have dark fill with cyan focus border
✓ Form type chips glow cyan when selected
✓ Submit button is gradient with glow
```

---

---

# PROMPT 9 — Auth Screens (Welcome + Login + Register)

> **Files:** `lib/features/auth/screens/welcome_screen.dart`, `lib/features/auth/screens/login_screen.dart`, `lib/features/auth/screens/register_screen.dart`  
> **Do NOT touch:** Auth logic, form validation, navigation, providers, or any other file.

```
Open these 3 files: 
- lib/features/auth/screens/welcome_screen.dart
- lib/features/auth/screens/login_screen.dart
- lib/features/auth/screens/register_screen.dart

VISUAL REDESIGN ONLY. Do not change any authentication logic or navigation.

FOR ALL 3 SCREENS — Apply these global styles:
- Background: Same RadialGradient background (Color(0xFF0D1F35) → Color(0xFF070B12))
- Input fields: Same dark styled inputs as Add Medicine (see Prompt 8 point 4)
- Primary buttons: Same gradient button style (cyan→blue, pill shape, 56px tall)

FOR welcome_screen.dart specifically:
- Feature chips (OCR Scan, Smart Reminders, etc.): 
  Styled as: Container(padding: symmetric(h:14, v:8), decoration: BoxDecoration(color: Color(0x0DFFFFFF), border: Border.all(color: Color(0x1AFFFFFF)), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(color: Colors.white, fontSize: 13)))
- "Already have an account? Log In" text: 
  Color: Color(0xFF00E5FF), fontSize: 15, fontWeight: w600
- Logo/icon area: Keep existing icon but wrap in Container with boxShadow: [BoxShadow(color: Color(0x4D00E5FF), blurRadius: 40, spreadRadius: 5)]

FOR login_screen.dart and register_screen.dart:
- Any section label / field label text: fontSize 13, color Color(0xFF8A9BB5)
- "Forgot Password?" link: color Color(0xFF00E5FF)
- "Don't have an account?" links: color Color(0xFF00E5FF)

After saving, run: flutter run -d ZT322VL7FR
Log out of the app to see auth screens. Take screenshots of Welcome, Login, Register.
Confirm:
✓ Welcome screen logo has glow effect
✓ Feature chips are glassmorphism style
✓ Login/Register inputs have dark fill and cyan focus
✓ Primary CTA button is gradient with glow
```

---

---

# PROMPT 10 — Medicine Detail Screen

> **File:** `lib/features/medicines/screens/medicine_detail_screen.dart`  
> **Do NOT touch:** Data loading, delete logic, navigation, or any other file.

```
Open ONLY the file: lib/features/medicines/screens/medicine_detail_screen.dart

VISUAL REDESIGN ONLY. Do not change data loading, delete logic, or navigation.

Apply these changes:

1. BACKGROUND: Same radial gradient background.

2. APP BAR: Transparent AppBar with cyan back arrow. Medicine name as title in white.

3. MEDICINE HERO CARD (top card with icon, name, form):
   Container(
     padding: EdgeInsets.all(24),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Color(0x1200E5FF), blurRadius: 20, offset: Offset(0,4))]),
     child: Row(children: [
       Container(width: 64, height: 64, decoration: BoxDecoration(color: Color(0xFF0D2840), borderRadius: BorderRadius.circular(16)), child: Center(child: Text(formEmoji, style: TextStyle(fontSize: 32)))),
       SizedBox(width: 16),
       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text(medicineName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
         SizedBox(height: 4),
         Text(formType, style: TextStyle(fontSize: 14, color: Color(0xFF8A9BB5))),
         SizedBox(height: 8),
         Container(padding: symmetric(h:12, v:4), decoration: BoxDecoration(color: Color(0x1A00E5FF), border: Border.all(color: Color(0xFF00E5FF)), borderRadius: BorderRadius.circular(16)), child: Text(strength, style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13))),
       ])),
     ]),
   )

4. DETAIL INFO ROWS:
   Each detail item (Category, Brand, Notes, etc.):
   Container(
     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
     decoration: BoxDecoration(color: Color(0xFF0D1826), border: Border.all(color: Color(0x1A00E5FF)), borderRadius: BorderRadius.circular(14)),
     child: Row(children: [
       Icon(relevantIcon, color: Color(0xFF00E5FF), size: 18),
       SizedBox(width: 12),
       Text(label, style: TextStyle(fontSize: 13, color: Color(0xFF8A9BB5))),
       Spacer(),
       Text(value, style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
     ]),
   )

5. REMINDER CHIPS:
   Each reminder time shown as:
   Container(padding: symmetric(h:14, v:6), decoration: BoxDecoration(color: Color(0x1A00E5FF), border: Border.all(color: Color(0xFF00E5FF).withOpacity(0.4)), borderRadius: BorderRadius.circular(20)), child: Text(time, style: TextStyle(color: Color(0xFF00E5FF), fontSize: 13)))

6. DELETE BUTTON:
   Container(width: double.infinity, height: 52, decoration: BoxDecoration(border: Border.all(color: Color(0xFFFF3B5C)), borderRadius: BorderRadius.circular(14)), child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.delete_rounded, color: Color(0xFFFF3B5C), size: 18), SizedBox(width: 8), Text('Delete Medicine', style: TextStyle(color: Color(0xFFFF3B5C), fontSize: 15, fontWeight: FontWeight.w600))])))

After saving, run: flutter run -d ZT322VL7FR
Tap on a medicine to open its detail screen. Take a screenshot. Confirm:
✓ Transparent AppBar
✓ Hero card with large form emoji (64px)
✓ Details shown in neon-bordered rows
✓ Reminder times as cyan chip badges
✓ Delete is outlined red (not solid red — it's a destructive action, outline is safer visually)
```

---

---

# 🔁 POST-COMPLETION CHECKLIST

Once all 10 prompts are done and verified, do a final pass through the app and check:

- [ ] All screens have consistent radial gradient background
- [ ] All cards have `Color(0xFF0D1826)` background + `Color(0x1A00E5FF)` border
- [ ] All section headers use the 3px cyan left bar pattern
- [ ] All primary action buttons are gradient cyan→blue with glow
- [ ] Bottom nav has cyan dot indicator on active tab
- [ ] Adherence ring is a donut shape (not filled circle) with outer glow
- [ ] Health metric cards show values prominently with colored accent lines
- [ ] Empty states have glowing emoji icons
- [ ] FAB button is gradient (not plain cyan circle)

---

# ⚡ TROUBLESHOOTING

**"App looks the same after prompt"**
1. Ask Antigravity: "Show me the exact git diff of what changed in [filename]"
2. Check if the file modification timestamp actually changed
3. Run `flutter clean` then `flutter run` (not just hot reload)
4. If changes exist but don't show: Check if `app_theme.dart` overrides them

**"App crashed / compile error after prompt"**
1. Ask Antigravity: "Show me the exact compile error"
2. Do NOT move to the next prompt until the error is fixed
3. Common issues: missing import, wrong Color syntax, unclosed brackets

**"Antigravity says done but screenshot looks wrong"**
1. Paste the verification checklist from the bottom of the prompt back to Antigravity
2. Say: "The screenshot does not show [specific item]. Fix only that item."
3. One visual problem = one targeted fix

---

*Document generated by Claude · MediFlow Project · February 21, 2026*
