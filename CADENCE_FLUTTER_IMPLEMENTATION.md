# CADENCE — FLUTTER GUI IMPLEMENTATION GUIDE
# Complete rebrand and UI overhaul of the MediFlow Flutter app
# Version 1.0 | For use with Antigravity, Claude, and Gemini agents

---

## WHAT THIS DOCUMENT IS

This is the complete instruction set for transforming the existing MediFlow Flutter app
into Cadence. The Stitch-generated screen images are the pixel-perfect visual target.
Every instruction in this document maps directly to those screens.

The Flutter project lives at:
`C:\Users\stive\OneDrive\Desktop\MediFlow_Flutter`

The app already works. All features are built. This is a GUI-only transformation.
Do NOT touch any business logic, providers, database schema, Firebase code,
notification logic, routing logic, or any .dart file that does not affect visual output.

---

## RULES FOR ALL AGENTS — READ BEFORE TOUCHING ANY FILE

1. **VISUAL ONLY.** Only modify files that affect appearance:
   `app_colors.dart`, `app_theme.dart`, `app_typography.dart`, screen `.dart` files,
   widget `.dart` files, `pubspec.yaml` (fonts only), `assets/`.
   Never touch providers, repositories, DAOs, models, routers, or services.

2. **ONE FILE AT A TIME.** Read the full file first. Then rewrite. Never partially edit
   a file and leave it in a broken state.

3. **PRESERVE ALL LOGIC.** Every `ref.watch()`, `ref.read()`, provider call, navigation
   call (`context.go()`, `context.push()`), and state variable must remain exactly as-is.
   Only change colors, text styles, layout, padding, and widget appearance.

4. **NO NEW PACKAGES** unless explicitly listed in the Dependencies section below.
   `google_fonts` is already installed — use it for DM Sans.

5. **COMPILE AFTER EVERY FILE.** Run `flutter analyze` after each file change.
   Fix any errors before moving to the next file.

6. **DARK MODE IS DEFAULT.** The app launches in dark mode. Light mode is toggled
   from Profile settings. Both must look exactly like their respective Stitch screens.

7. **NEVER HARDCODE COLORS.** Every color must reference `AppColors.xxx` constants.
   No raw hex values anywhere in widget files.

8. **FONT IS DM SANS EVERYWHERE.** Replace all Inter references with DM Sans.
   Use `GoogleFonts.dmSans()` for all text styles.

---

## STEP 1 — UPDATE PUBSPEC.YAML (fonts only)

In `pubspec.yaml`, locate the `google_fonts` dependency. It is already there.
No new packages needed — DM Sans is served by `google_fonts` at runtime.

Remove any manually declared font assets for Inter if present. DM Sans is fetched
via the `google_fonts` package automatically.

---

## STEP 2 — REWRITE app_colors.dart

File path: `lib/core/theme/app_colors.dart`

Replace the entire file content with the following:

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color coral        = Color(0xFFFF5C35);
  static const Color coralLight   = Color(0xFFFF8A65);
  static const Color coralPressed = Color(0xFFE54E2A);
  static const Color yellow       = Color(0xFFFFD60A);
  static const Color yellowDark   = Color(0xFFCC9900); // for light mode text

  // ── Dark Mode Backgrounds ──────────────────────────────────────────────────
  static const Color bgDark       = Color(0xFF111111);
  static const Color cardDark     = Color(0xFF1A1A1A);
  static const Color cardElevDark = Color(0xFF212121);
  static const Color inputDark    = Color(0xFF242424);
  static const Color dividerDark  = Color(0xFF2A2A2A);

  // ── Light Mode Backgrounds ─────────────────────────────────────────────────
  static const Color bgLight      = Color(0xFFF5F5F5);
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color cardElevLight= Color(0xFFFAFAFA);
  static const Color inputLight   = Color(0xFFEFEFEF);
  static const Color dividerLight = Color(0xFFE0E0E0);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimaryDark    = Color(0xFFFFFFFF);
  static const Color textSecondaryDark  = Color(0xFF999999);
  static const Color textTertiaryDark   = Color(0xFF555555);
  static const Color textPrimaryLight   = Color(0xFF111111);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight  = Color(0xFFAAAAAA);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF10D98C);
  static const Color successDark  = Color(0xFF059669); // light mode
  static const Color warning      = Color(0xFFF59E0B);
  static const Color error        = Color(0xFFEF4444);

  // ── Role accents ───────────────────────────────────────────────────────────
  static const Color indigo       = Color(0xFF6366F1);
  static const Color premiumStart = Color(0xFF8B5CF6);
  static const Color premiumEnd   = Color(0xFFEC4899);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [coral, coralLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumStart, premiumEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tipGradient = LinearGradient(
    colors: [success, coral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgLightGradient = LinearGradient(
    colors: [Color(0xFFFFF5F2), Color(0xFFFFFDF5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Badge fill colors (low opacity) ───────────────────────────────────────
  static const Color takenFill    = Color(0xFF0A2A1A);
  static const Color skippedFill  = Color(0xFF2A2000);
  static const Color missedFill   = Color(0xFF2A0A0A);
}
```

---

## STEP 3 — REWRITE app_typography.dart

File path: `lib/core/theme/app_typography.dart`

Replace entire file:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get display => GoogleFonts.dmSans(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark, letterSpacing: -0.5,
  );

  static TextStyle get h1 => GoogleFonts.dmSans(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryDark,
  );

  static TextStyle get h2 => GoogleFonts.dmSans(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  static TextStyle get h3 => GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimaryDark,
  );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
  );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondaryDark,
  );

  static TextStyle get label => GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.coral,
  );

  static TextStyle get caption => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textTertiaryDark,
    letterSpacing: 0.08,
  );

  static TextStyle get buttonText => GoogleFonts.dmSans(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get code => GoogleFonts.sourceCodePro(
    fontSize: 20, fontWeight: FontWeight.w700,
    color: AppColors.coral,
    letterSpacing: 2,
  );
}
```

---

## STEP 4 — REWRITE app_theme.dart

File path: `lib/core/theme/app_theme.dart`

Replace entire file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.coral,
      secondary: AppColors.yellow,
      surface: AppColors.cardDark,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.coral,
      unselectedItemColor: AppColors.textTertiaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dividerDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dividerDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.coral, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14, color: AppColors.textTertiaryDark,
      ),
      prefixIconColor: AppColors.textTertiaryDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 0.5,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : AppColors.textTertiaryDark),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.coral : AppColors.dividerDark),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.coral : Colors.transparent),
      side: const BorderSide(color: AppColors.textTertiaryDark),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.coral : AppColors.textTertiaryDark),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.coral,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.inputDark,
      selectedColor: AppColors.coral,
      labelStyle: GoogleFonts.dmSans(fontSize: 13, color: Colors.white),
      side: const BorderSide(color: AppColors.dividerDark),
      shape: const StadiumBorder(),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardDark,
      contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.coral,
      secondary: AppColors.yellow,
      surface: AppColors.cardLight,
      error: AppColors.error,
    ),
    textTheme: GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardLight,
      selectedItemColor: AppColors.coral,
      unselectedItemColor: AppColors.textTertiaryLight,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dividerLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dividerLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.coral, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14, color: AppColors.textTertiaryLight,
      ),
      prefixIconColor: AppColors.textTertiaryLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.dividerLight, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 0.5,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? Colors.white : AppColors.textTertiaryLight),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.coral : AppColors.dividerLight),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.coral,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}
```

---

## STEP 5 — CREATE SHARED WIDGETS

### 5a — App Background Widget

Create file: `lib/core/widgets/app_background.dart`

This widget wraps every screen's body. It renders the dark starfield background
(dark mode) or the warm gradient (light mode).

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});
  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> {
  static List<_Star>? _cachedStars;
  static List<_Star> get _stars {
    _cachedStars ??= List.generate(45, (_) {
      final rng = Random();
      return _Star(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: rng.nextDouble() * 1.5 + 0.5,
        opacity: rng.nextDouble() * 0.12 + 0.05,
      );
    });
    return _cachedStars!;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        // Base background
        Positioned.fill(
          child: isDark
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0, -0.7),
                      radius: 0.9,
                      colors: [Color(0xFF1A0A00), AppColors.bgDark],
                      stops: [0.0, 0.55],
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF5F2), Color(0xFFFFFDF5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
        ),
        // Star particles (dark mode only)
        if (isDark)
          Positioned.fill(
            child: CustomPaint(painter: _StarPainter(_stars)),
          ),
        // Content
        widget.child,
      ],
    );
  }
}

class _Star {
  final double x, y, size, opacity;
  const _Star({required this.x, required this.y, required this.size, required this.opacity});
}

class _StarPainter extends CustomPainter {
  final List<_Star> stars;
  const _StarPainter(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    for (final s in stars) {
      canvas.drawCircle(
        Offset(s.x * size.width, s.y * size.height),
        s.size,
        Paint()..color = Colors.white.withOpacity(s.opacity),
      );
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 5b — Cadence Logo Widget

Create file: `lib/core/widgets/cadence_logo.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CadenceLogo extends StatelessWidget {
  final double size;
  const CadenceLogo({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;

    // Coral ring
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = AppColors.coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.045
        ..isAntiAlias = true,
    );

    // Yellow ECG pulse line
    final path = Path();
    final y = cy;
    final segW = size.width / 8;
    path.moveTo(cx - segW * 3, y);
    path.lineTo(cx - segW * 1.2, y);
    path.lineTo(cx - segW * 0.6, y - size.height * 0.22);
    path.lineTo(cx, y + size.height * 0.18);
    path.lineTo(cx + segW * 0.5, y - size.height * 0.1);
    path.lineTo(cx + segW, y);
    path.lineTo(cx + segW * 3, y);

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.038
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
```

### 5c — Gradient Button Widget

Create file: `lib/core/widgets/coral_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CoralButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CoralButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.primaryGradient : null,
          color: enabled ? null : (Theme.of(context).brightness == Brightness.dark
              ? AppColors.dividerDark : const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.white : AppColors.textTertiaryDark,
                  ),
                ),
        ),
      ),
    );
  }
}
```

### 5d — Adherence Ring Widget

Create file: `lib/core/widgets/adherence_ring.dart`

CRITICAL: This renders as an ARC, not a filled circle. The interior is transparent.

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AdherenceRing extends StatefulWidget {
  final double percentage; // 0.0 to 100.0
  final double size;

  const AdherenceRing({
    super.key,
    required this.percentage,
    this.size = 180,
  });

  @override
  State<AdherenceRing> createState() => _AdherenceRingState();
}

class _AdherenceRingState extends State<AdherenceRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = Tween<double>(begin: 0, end: widget.percentage / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: _anim.value,
            isDark: isDark,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(widget.percentage).toInt()}%',
                  style: GoogleFonts.dmSans(
                    fontSize: widget.size * 0.178,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    height: 1.0,
                  ),
                ),
                Text(
                  'adherence',
                  style: GoogleFonts.dmSans(
                    fontSize: widget.size * 0.072,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  const _RingPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 12;
    const strokeW = 10.0;
    const startAngle = -pi / 2;

    // Track ring
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..isAntiAlias = true,
    );

    if (progress <= 0) return;

    // Coral glow (dark mode only)
    if (isDark) {
      final glowRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      canvas.drawArc(
        glowRect,
        startAngle,
        2 * pi * progress,
        false,
        Paint()
          ..color = AppColors.coral.withOpacity(0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeW + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..isAntiAlias = true,
      );
    }

    // Progress arc with gradient
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final shader = const LinearGradient(
      colors: [AppColors.coral, AppColors.coralLight],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      startAngle,
      2 * pi * progress,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
```

### 5e — Avatar Circle Widget

Create file: `lib/core/widgets/avatar_circle.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarCircle({super.key, required this.initials, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

---

## STEP 6 — SCREEN-BY-SCREEN IMPLEMENTATION

For each screen file, apply the changes described below.
The Flutter file locations are under `lib/features/`.

---

### SPLASH SCREEN
**File:** `lib/features/splash/screens/splash_screen.dart`

Changes:
- Wrap `Scaffold` body with `AppBackground` widget.
- Replace the existing logo/icon widget with `CadenceLogo(size: 72)`.
- Change app name text to "Cadence" using `AppTypography.display`.
- Change tagline to "Medication at your rhythm." italic, `AppColors.textSecondaryDark`.
- Replace loading indicator with a horizontal pill progress bar:
  `Container(width: 120, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColors.dividerDark))` as track, overlaid with `Container(width: 72, height: 3, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColors.coral))` for 60% fill.
- Center all content perfectly using `Center` → `Column(mainAxisSize: MainAxisSize.min)`.
- Light mode: same layout, background uses `AppBackground` (auto-detects theme).

---

### ONBOARDING SCREEN
**File:** `lib/features/auth/screens/onboarding_screen.dart`

Changes:
- Wrap body with `AppBackground`.
- Page 1 icon: Bell icon `Icons.notifications_outlined`, 48px, `AppColors.coral`, inside `Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.cardDark))` with a soft coral radial glow using `BoxDecoration` boxShadow `[BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)]`.
- Page 2 icon: Heart with ECG — use `Icons.monitor_heart_outlined`, coral, same circle container with a red/pink glow.
- Page 3 icon: `Icons.shield_outlined`, coral, same style.
- Titles: `AppTypography.h1` white.
- Body text: `AppTypography.bodyMedium`.
- Slide dots: active dot is a `Container(width: 20, height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: AppColors.coral))`. Inactive: `Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.dividerDark))`.
- Buttons: Replace with `CoralButton`.
- "Skip" button: `TextButton` with `AppColors.coral` text.
- NO bottom nav bar on any of the 3 onboarding pages.

---

### ROLE SELECTION SCREEN
**File:** `lib/features/auth/screens/role_selection_screen.dart`

Changes:
- Wrap body with `AppBackground`.
- Remove any bottom navigation bar — this is a pre-auth screen.
- Logo at top: `CadenceLogo(size: 48)`.
- Title "Welcome to Cadence": `AppTypography.h1` white.
- Subtitle "I am a...": `AppTypography.bodyMedium`.
- Three role cards. Each card: `Container` with `decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(16))`.
  - Patient card icon circle: `AppColors.coral` background.
  - Caregiver card icon circle: `AppColors.indigo` background.
  - Invite Code card icon circle: `AppColors.coral` background.
- **SELECTED STATE** (Patient or Caregiver or Invite):
  - Add `border: Border.all(color: selectedColor, width: 2)` to the card decoration.
  - Add color tint: `color: selectedColor.withOpacity(0.06)` overlay on card.
  - Show coral checkmark circle badge `(width: 20, height: 20)` at top-right of selected card.
- "Continue" button:
  - Disabled (no selection): `Container` with `AppColors.dividerDark` color, `AppColors.textTertiaryDark` text. NOT `CoralButton` — a plain grey pill.
  - Active (selection made): `CoralButton(label: 'Continue', onPressed: ...)`.
- "You can change this later in Profile": `AppTypography.caption` centered.
- NO bottom nav bar.

---

### WELCOME SCREEN
**File:** `lib/features/auth/screens/welcome_screen.dart`

Changes:
- Wrap body with `AppBackground`.
- Logo: `CadenceLogo(size: 72)` with `BoxShadow(color: AppColors.coral.withOpacity(0.35), blurRadius: 40, spreadRadius: 2)` for glow.
- App name "Cadence": `AppTypography.display`.
- Tagline "Your Smart Medication Companion": `AppTypography.bodyMedium` italic.
- Feature chips (4 items in 2×2 grid, `Wrap` widget):
  Each chip: `Container(padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.dividerDark)))`.
  Text: `AppTypography.bodySmall` white. Icons as emoji prefix.
  Light mode: `AppColors.cardLight` fill, `AppColors.dividerLight` border, `AppColors.textPrimaryLight` text.
- "Create Account" button: `CoralButton`.
- "Already have an account? Log In": plain text + coral `InkWell` for "Log In".
- Disclaimer: `AppTypography.caption` italic, centered, bottom.
- NO bottom nav. NO social login buttons.

---

### LOGIN SCREEN
**File:** `lib/features/auth/screens/login_screen.dart`

Changes:
- Background: `AppBackground`.
- AppBar: transparent, "Welcome Back" title, back arrow.
- Logo: `CadenceLogo(size: 64)`. **IMPORTANT:** Remove any existing logo that renders as a yellow square/app icon. The logo must be the `CadenceLogo` custom painter widget only.
- App name: `AppTypography.h2`.
- Tagline: italic `AppTypography.bodySmall`.
- Inputs: `AppColors.inputDark` fill, coral focus border. Already handled by `AppTheme`.
- "Forgot Password?": right-aligned `TextButton` with `AppColors.coral`.
- "Log In": `CoralButton`.
- "Register" link: coral colored text inline.
- NO social login section. NO Google/Apple buttons.

---

### REGISTER SCREENS (3 variants)
**Files:**
- `lib/features/auth/screens/register_screen.dart`
- (or separate files for each role variant if they exist)

Changes apply to all 3 register variants (Patient, Caregiver, Invite Code):
- Background: `AppBackground`.
- AppBar: transparent, "Create Account", back arrow.
- Role badge: `Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), border: Border.all(color: badgeColor)))`.
  - Patient: `AppColors.coral` border + text.
  - Caregiver: `AppColors.indigo` border + text.
  - Patient with Caregiver: `AppColors.coral`.
- Inputs: standard theme inputs.
- Caregiver optional section:
  - "Link a Patient (optional)" / "Connect with Caregiver (optional)": coral text, SemiBold.
  - Toggle: theme switch (coral when ON).
  - When toggle ON: animate in the invite code input field.
- Invite Code register variant: monospace-style code input, amber hint text `AppColors.warning`.
- Divider with label: `Row` with `Divider` on each side + text in center.
- "Create Account": `CoralButton`.
- Sign In link: coral.
- NO bottom nav bar.

---

### HOME SCREEN
**File:** `lib/features/home/screens/home_screen.dart`

Changes:
- Background: `AppBackground`.
- Avatar: replace existing avatar widget with `AvatarCircle(initials: userInitials, size: 44)`.
- Greeting text: `AppTypography.bodyMedium` (secondary color).
- User name: `AppTypography.h1`.
- Bell icon: `Icons.notifications_outlined`, white.
- Stats row: 3 equal `Expanded` cards, `AppColors.cardDark`, `borderRadius: 12`.
  Each card: icon in coral, number in `AppTypography.h2` white, label in `AppTypography.bodySmall`.
  **FIX:** Use `Row(children: [Expanded(...), SizedBox(width: 8), Expanded(...), SizedBox(width: 8), Expanded(...)])` to guarantee all 3 fit within screen width. Never use fixed widths.
- Adherence ring: replace existing ring widget with `AdherenceRing(percentage: adherenceValue, size: 180)`.
- "Progress for last 30 days": `AppTypography.caption` centered below ring.
- Section headers: "Today's Schedule 💊" `AppTypography.h3` left, "View all" `AppColors.coral` right.
- Schedule cards (`AppColors.cardDark`, radius 16):
  - TAKEN: mint green checkmark circle + medicine name + TAKEN badge (mint green bordered chip).
  - NEXT DOSE: pill icon + name + NEXT DOSE badge (coral fill). Action buttons row below:
    - "Took It": `CoralButton` but smaller height 40px, no full-width (use `SizedBox(width: 110)`).
    - "Skip": `Container` with `AppColors.cardElevDark` fill, white text.
    - "Snooze": `Container` with `AppColors.cardElevDark` fill, `AppColors.yellow` text.
- "My Medicines" / "See All →": same section header pattern.
- Medicine cards: 2-column grid, `AppColors.cardDark`, radius 12.
- Health Tip card: `AppColors.tipGradient` gradient, radius 16, white text.
- **FIX:** Scroll content must have `padding: EdgeInsets.only(bottom: 100)` to prevent FAB overlap.
- FAB: `FloatingActionButton(backgroundColor: AppColors.coral, child: Icon(Icons.add, color: Colors.white))`. The FAB gradient can be achieved by wrapping with `Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle))` and using a plain `IconButton` inside if `FloatingActionButton` doesn't support gradients natively.
- Bottom nav: Home ACTIVE coral, others muted.
- Light mode: same layout, `AppColors.cardLight` cards, `AppColors.textPrimaryLight` text.

---

### HEALTH DASHBOARD SCREEN
**File:** `lib/features/health/screens/health_screen.dart`

Changes:
- Background: `AppBackground` (no star glow needed here — just plain dark bg).
- Title: "Health Dashboard" `AppTypography.h1`.
- Subtitle: "Track your vital signs" `AppTypography.bodyMedium`.
- Grid/List toggle: active button has `AppColors.coral` background, inactive muted.
- 13 metric cards: `AppColors.cardDark`, radius 16, **2px top border accent** per metric using `Border(top: BorderSide(color: metricColor, width: 2))`.
  Metric name: 11px uppercase `AppColors.textTertiaryDark`. Value: `AppTypography.h2` white. Unit inline with value.
- FAB: coral gradient.
- Bottom nav: Health ACTIVE.

---

### MEDICATION HISTORY SCREEN
**File:** `lib/features/history/screens/history_screen.dart`

Changes:
- Background: `AppBackground`.
- Title: "Medication History" `AppTypography.h1`.
- Adherence summary card: `AppColors.cardDark`, radius 16, coral 3px left border (`Border(left: BorderSide(color: AppColors.coral, width: 3))`).
  - Adherence ring: `AdherenceRing(size: 140)` centered.
  - Stat chips row: pill-shaped chips with colored borders:
    - Taken: `AppColors.success` border + text, `AppColors.takenFill` background.
    - Skipped: `AppColors.yellow` border + text, `AppColors.skippedFill` background.
    - Missed: `AppColors.error` border + text, `AppColors.missedFill` background.
- Date filter chips: "Today" active = coral fill white text. Inactive = `AppColors.cardDark`.
- Status filter chips: same pattern.
- Group date headers: "TODAY — OCT 24" style, `AppTypography.caption` uppercase.
- History rows:
  - TAKEN: mint green circle check icon + medicine name + time + TAKEN badge.
  - SKIPPED: yellow warning icon + name + time + SKIPPED badge (yellow bordered).
  - MISSED: red × icon + name + time + MISSED badge (red bordered).
- Bottom nav: History ACTIVE.

---

### PROFILE SCREEN
**File:** `lib/features/profile/screens/profile_screen.dart`

This screen has 4 visual states. The logic is already built. Only change visuals:

**All states common:**
- Background: `AppBackground`.
- Avatar: `AvatarCircle(initials: userInitials, size: 80)`.
- Name: `AppTypography.h1`.
- Email: `AppTypography.bodyMedium`.
- Role badge: coral or indigo outlined pill chip.
- Stats grid 2×3: `AppColors.cardDark` cards (light: white), 12px radius, 8px gap.
  Adherence value in `AppColors.coral`. All others white (dark) / `AppColors.textPrimaryLight` (light).

**MY CAREGIVER / MY PATIENT section:**
- Section header: 11px uppercase `AppColors.textTertiaryDark`.
- Card: `AppColors.cardDark`, 16px radius.
  - UNLINKED: indigo 3px left border. Indigo icon. "Connect with Caregiver" / "Link a Patient" button: outlined ghost style with indigo border + text.
  - LINKED: green 3px left border `AppColors.success`. `AvatarCircle(size: 40)` + name + "Linked ✓" in green. "Unlink" in `AppColors.error` (patient side) or "View Dashboard" small coral outlined pill (caregiver side).

**Premium card:** `AppColors.premiumGradient` decoration. White text. White CTA button with purple text.

**Settings rows:**
- Language row: globe icon + label + current language flag+name right + chevron.
- Notifications: bell icon + toggle. Toggle uses theme switch (coral = ON).
- Dark Mode: moon icon + toggle.
- Export row: upload icon + label + chevron.
- Cloud Backup: cloud icon + "PRO" badge (purple chip) + chevron.
- My Role: person icon + role name + chevron.
- About Cadence: info icon + "v1.0.0" + chevron.
- Log Out: exit icon in red tint + "Log Out" in `AppColors.error` + chevron.

- Bottom nav: Profile ACTIVE.

---

### ADD MEDICINE SCREEN
**File:** `lib/features/medicines/screens/add_medicine_screen.dart`

Changes:
- No `AppBackground` (plain dark bg is fine for form screens).
- AppBar: transparent, "Add Medicine", coral "Save" action.
- "OCR Scan" badge: small coral outlined chip top-right.
- Section headers: `AppTypography.caption` uppercase.
- Form inputs: standard theme.
- Form type chips: "Tablet" active = coral fill, others = dark outlined pill.
- Reminder preset buttons: coral outlined pill chips.
- Medical disclaimer card: `AppColors.cardDark`, amber 3px left border `AppColors.warning`.
- "Confirm & Add Medicine": `CoralButton`.

---

### MEDICINE DETAIL SCREEN
**File:** `lib/features/medicines/screens/medicine_detail_screen.dart`

Changes:
- AppBar: transparent, medicine name, back arrow.
- Identity card: `AppColors.cardDark`, coral pill icon circle left.
- Detail rows card: section header 11px uppercase, label/value rows with dividers.
- Reminders card: "+ Add" in coral right.
- 7-day history dots: Mon–Sun circles. Colors:
  - Taken: `AppColors.coral`.
  - Skipped: `AppColors.yellow`.
  - Missed: `AppColors.error`.
  - Mint alternate for variety: `AppColors.success`.
- Medical disclaimer card: amber left border.
- Bottom action row: `CoralButton` (Set Reminder) + outlined ghost (Edit) + danger outlined (Delete).

---

### REMINDER SETUP SCREEN
**File:** `lib/features/reminders/screens/reminder_setup_screen.dart`

Changes:
- Step cards: `AppColors.cardDark`, 16px radius.
- Step headers: `AppTypography.caption` uppercase with step number.
- Time preset chips: coral outlined, 44px height.
- Added time chip: coral fill, white "×" dismiss.
- Radio buttons: coral active.
- Toggles: coral when ON.
- Snooze duration chips: "5 min" active coral fill.
- "Save Reminder": `CoralButton`.

---

### CAREGIVER DASHBOARD SCREEN
**File:** `lib/features/caregiver/screens/caregiver_dashboard_screen.dart`

Changes:
- Background: `AppBackground`.
- AppBar: "Cadence Caregiver", gear settings icon.
- Patient header card: `AppColors.cardDark`. `AvatarCircle` for patient. "PATIENT" coral chip.
- Adherence ring: `AdherenceRing(size: 120)`. "DAILY" label below.
- Stat chips: TAKEN green, PENDING yellow, MISSED red — bordered pill chips.
- 7-Day Trend card: coral bar chart bars on dark background. "Weekly Avg: 92%" in coral right.
- Schedule rows: TAKEN green badge, PENDING yellow badge.
- FAB: coral gradient, pencil/edit icon.
- Bottom nav: Profile ACTIVE (caregiver accesses this from Profile).

---

### CAREGIVER DASHBOARD EMPTY SCREEN
**File:** `lib/features/caregiver/screens/caregiver_dashboard_empty_screen.dart`
(or the empty state branch of caregiver_dashboard_screen.dart)

Changes:
- Background: `AppBackground`.
- Empty state: indigo circle 72px with glow, "No Patient Linked" `AppTypography.h2`.
- Invite code card: `AppColors.cardDark`, indigo 3px left border.
  - Code display box: coral 10% fill + dashed coral border + "CD-4A7X" monospace coral text.
  - "Share Invite Code": `CoralButton`.
  - "Expires in 24 hours": `AppColors.warning` amber text.
- Divider with "OR".
- Code input + "Link Patient": `CoralButton`.

---

### CONNECT CAREGIVER SCREEN
**File:** `lib/features/caregiver/screens/connect_caregiver_screen.dart`

Changes:
- Background: `AppBackground`.
- Indigo icon circle 80px with glow.
- Code input: 56px height, coral focus border.
- "Connect": `CoralButton`.
- "I don't have a code": coral ghost text link.
- Info card: `AppColors.cardDark`, coral 3px left border.
- Bottom nav: Profile ACTIVE.

---

### LINK PATIENT SCREEN
**File:** `lib/features/caregiver/screens/link_patient_screen.dart`

Changes:
- Background: `AppBackground`.
- Coral icon circle 80px with glow.
- Invite code card: indigo 3px left border. Code display box: dashed coral border.
- "Share Invite Code": `CoralButton`.
- Divider with OR. Code input + "Link Patient": `CoralButton`.
- Bottom nav: Profile ACTIVE.

---

### LINK SUCCESS SCREEN
**File:** `lib/features/caregiver/screens/link_success_screen.dart`

Changes:
- Background: `AppBackground` (star particles visible).
- Coral circle 80px with white checkmark, coral outer glow.
- "Successfully Connected!" `AppTypography.h2`.
- Body text: `AppTypography.bodyMedium`.
- Indigo pill chip "Maria → Stiven": `AppColors.indigo` fill white text.
- "Go to Dashboard": `CoralButton`.
- "Done": coral ghost text.
- NO bottom nav bar.

---

### DATA EXPORT SCREEN
**File:** `lib/features/profile/screens/data_export_screen.dart`

Changes:
- AppBar: "Export & Share".
- Format cards: selected has coral 2px border. Unselected dark card no border.
- Include section: checkboxes coral when checked.
- Date range chips: active coral.
- JSON preview card: dark card, coral left border, code block with `AppColors.cardElevDark` bg + `AppColors.success` monospace text.
- "Generate & Share": `CoralButton`.
- Bottom nav: Profile ACTIVE.

---

### ABOUT CADENCE SCREEN
**File:** `lib/features/profile/screens/about_screen.dart`

Changes:
- `CadenceLogo(size: 72)` centered.
- "Cadence" `AppTypography.display`.
- "Version 1.0.0 (Build 1)" `AppTypography.caption`.
- "© 2026 Cadence Health" `AppTypography.caption`.
- About card: `AppColors.cardDark`.
- Medical disclaimer card: amber left border.
- Links rows: chevron right. "Rate Cadence ⭐" star icon `AppColors.coral`.
- Bottom nav: Profile ACTIVE.
- **IMPORTANT:** Replace all "MediFlow" text with "Cadence" everywhere in this file.

---

### LANGUAGE SELECTION SCREEN
**File:** `lib/features/profile/screens/language_selection_screen.dart`

Changes:
- Language rows: `AppColors.cardDark`, 12px radius.
- Selected language: coral checkmark right side.
- "Apply": `CoralButton`.
- Bottom nav: Profile ACTIVE.

---

### SNOOZE BOTTOM SHEET
**File:** `lib/features/home/widgets/snooze_bottom_sheet.dart`

Changes:
- Bottom sheet container: `AppColors.cardDark`, top corners 20px radius.
- Drag handle: `AppColors.dividerDark`.
- Medicine name: `AppTypography.bodyMedium`.
- Snooze option cards: `AppColors.inputDark`, 12px radius. Selected: coral 2px border.
- "Snooze": `CoralButton`.
- "Dismiss": coral ghost text.

---

### SCAN MEDICINE SCREEN
**File:** `lib/features/scan/screens/scan_screen.dart`

Changes:
- Full screen, no bottom nav.
- Corner brackets: `AppColors.coral`, 3px thick, 24px arm length. Draw with `CustomPaint`.
- Capture button: `Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.coral, width: 3)))` with `AppColors.coral` inner fill.
- Flash icon: white.
- "MANUAL" text: white.
- Scanning line: coral horizontal line animated up-down within frame bounds.

---

## STEP 7 — GLOBAL TEXT REPLACEMENTS

Search the entire `lib/` directory and replace ALL occurrences of:

| Find | Replace |
|------|---------|
| `MediFlow` | `Cadence` |
| `mediflow` | `cadence` |
| `Your Smart Medicine Companion` | `Your Smart Medication Companion` |
| `Medication at your rhythm` | `Medication at your rhythm.` |
| `MF-` | `CD-` (invite code prefix only — check context) |
| `Inter` (font references) | `DmSans` or `dmSans` |
| `Color(0xFF00D4D4)` | `AppColors.coral` |
| `Color(0xFF00A3A3)` | `AppColors.coralLight` |
| `Color(0xFF0D1B2A)` | `AppColors.bgDark` |
| `Color(0xFF162032)` | `AppColors.cardDark` |
| `Color(0xFF1A2B3C)` | `AppColors.inputDark` |
| `Color(0xFF8FA3B8)` | `AppColors.textSecondaryDark` |
| `Color(0xFFF0FAFA)` | `AppColors.bgLight` |

After text replacement: run `flutter analyze` and fix any errors.

---

## STEP 8 — KNOWN BUGS TO FIX DURING IMPLEMENTATION

These are issues visible in the Stitch screens that must be corrected in Flutter:

**BUG 1 — FAB overlapping content (Home screen)**
The FAB in `home_screen_dark` overlaps the "My Medicines" header and the "NEXT DOSE"
badge in the second schedule card. Fix: ensure `CustomScrollView` or `ListView` has
`padding: EdgeInsets.only(bottom: 96)` at the bottom of all scrollable content.

**BUG 2 — Splash content not perfectly centered**
The splash screen content group sits slightly below vertical center.
Fix: use `Center` widget wrapping a `Column(mainAxisSize: MainAxisSize.min)`.
Do not use `Column` with spacers that add asymmetric gaps.

**BUG 3 — Login logo renders wrong**
Remove any `Image.asset('assets/icon/...')` or `FlutterLogo` from login screen.
Replace with `CadenceLogo(size: 64)` only.

**BUG 4 — Role selection nav bar leak**
Any role/welcome/register/login screen that shows the bottom navigation bar
must have it removed. Wrap these screens in a `Scaffold` without a
`bottomNavigationBar` property, separate from the `MainTabNavigator` scaffold.

**BUG 5 — Adherence ring filled circle**
If the existing `AdherenceRing` or any equivalent widget renders as a solid filled
circle, delete it entirely and use the new `AdherenceRing` widget from Step 5d.
The new widget uses `PaintingStyle.stroke` — never `PaintingStyle.fill`.

---

## STEP 9 — LIGHT MODE VERIFICATION

After all dark mode screens are implemented and compiling, switch to light mode
in the app and verify each screen against the light mode Stitch images.

Light mode rules:
- All backgrounds: `AppBackground` auto-applies light gradient.
- All cards: `AppColors.cardLight` (white) with `AppColors.dividerLight` border.
- All primary text: `AppColors.textPrimaryLight` (#111111).
- All secondary text: `AppColors.textSecondaryLight` (#666666).
- Bottom nav: `AppColors.cardLight` background.
- Adherence ring track: `Color(0xFFE0E0E0)`.
- Dark Mode toggle: shown as OFF.

The `AppTheme.light` definition already handles most of this automatically.
The main manual fix is ensuring every widget that hardcodes a dark color
respects `Theme.of(context).brightness`.

Pattern to use everywhere a color depends on theme:
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;
final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
```

---

## STEP 10 — FINAL CHECKLIST

Before marking implementation complete, verify every item:

- [ ] App name "Cadence" appears on Splash, Welcome, Login, About screens
- [ ] Tagline "Medication at your rhythm." on Splash and Welcome
- [ ] Coral (#FF5C35) is the active/brand color throughout — no teal or cyan anywhere
- [ ] Electric yellow (#FFD60A) appears on logo ECG line, snooze button text, and streak stat
- [ ] DM Sans font renders on all screens (check with a font debug overlay if needed)
- [ ] CadenceLogo renders correctly (ring + ECG line, not a square icon)
- [ ] Adherence ring is an arc with transparent interior — not a filled disc
- [ ] Star particles visible on dark mode backgrounds
- [ ] No bottom nav bar on: Splash, Onboarding x3, Role Selection x6, Welcome, Login, Register x3, Link Success
- [ ] Bottom nav Home/Health/History/Profile present on all post-auth screens
- [ ] Correct tab highlighted as ACTIVE on each screen
- [ ] FAB visible above nav bar without overlapping content
- [ ] All "MediFlow" text replaced with "Cadence"
- [ ] All invite code prefixes show "CD-" not "MF-"
- [ ] Light mode: all backgrounds warm cream gradient, all cards white
- [ ] Light mode: Dark Mode toggle shown as OFF
- [ ] Premium card: purple→pink gradient (unchanged from MediFlow)
- [ ] Caregiver screens: indigo (#6366F1) used for caregiver-specific elements
- [ ] No social login buttons anywhere
- [ ] No real photos or stock avatars — initials circles only

---

## DEPENDENCIES (no new packages needed)

All required packages are already in `pubspec.yaml`:
- `google_fonts` → provides DM Sans via `GoogleFonts.dmSans()`
- `flutter_riverpod` → state management (do not touch)
- `go_router` → navigation (do not touch)
- `drift` → database (do not touch)
- `flutter_local_notifications` → reminders (do not touch)

Only package action needed:
Run `flutter pub get` once after any `pubspec.yaml` change.

---

## FILE CREATION SUMMARY

New files to create:
1. `lib/core/widgets/app_background.dart`
2. `lib/core/widgets/cadence_logo.dart`
3. `lib/core/widgets/coral_button.dart`
4. `lib/core/widgets/adherence_ring.dart`
5. `lib/core/widgets/avatar_circle.dart`

Files to fully rewrite:
1. `lib/core/theme/app_colors.dart`
2. `lib/core/theme/app_typography.dart`
3. `lib/core/theme/app_theme.dart`

Files to visually update (preserve all logic):
- Every screen `.dart` file listed in Step 6 above

---

END OF DOCUMENT
