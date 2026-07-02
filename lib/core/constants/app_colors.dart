import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────
  static const Color pageBackground = Color(0xFFF2F4F8);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF7F9FC);

  // ── Brand palette ────────────────────────────
  static const Color primary      = Color(0xFF2D7DD2);
  static const Color primaryDark  = Color(0xFF1A4F8A);
  static const Color primaryLight = Color(0xFFE8F1FB);
  static const Color darkButton   = Color(0xFF141B2D);

  // ── Role accents ─────────────────────────────
  static const Color caregiver      = Color(0xFF5B6EF5);
  static const Color caregiverLight = Color(0xFFEEF0FF);
  static const Color linked         = Color(0xFFF5A623);
  static const Color linkedLight    = Color(0xFFFFF3E0);

  // ── Semantic ─────────────────────────────────
  static const Color success      = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger       = Color(0xFFEF4444);
  static const Color dangerLight  = Color(0xFFFEE2E2);

  // ── Text ─────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary  = Color(0xFFCBD5E1);
  static const Color border        = Color(0xFFE2E8F0);
  static const Color divider       = Color(0xFFF1F5F9);

  // ── Shadows ──────────────────────────────────
  static List<BoxShadow> get xs => const [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];
  static List<BoxShadow> get sm => const [
    BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x05000000), blurRadius: 3, offset: Offset(0, 1)),
  ];
  static List<BoxShadow> get md => const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> get lg => const [
    BoxShadow(color: Color(0x14000000), blurRadius: 40, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 4)),
  ];
  static List<BoxShadow> coloredShadow(Color c, {double opacity = 0.25}) => [
    BoxShadow(
      color: c.withValues(alpha: opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Decorations ──────────────────────────────
  static BoxDecoration get card => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: md,
  );
  static BoxDecoration get cardLg => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(28),
    boxShadow: md,
  );
  static BoxDecoration gradientCard(List<Color> colors, {double radius = 24}) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: coloredShadow(colors.first),
      );
  static BoxDecoration pill(Color c, {bool filled = true, double opacity = 0.1}) =>
      BoxDecoration(
        color: filled ? c : c.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(100),
        border: filled ? null : Border.all(color: c.withValues(alpha: 0.2)),
      );

  // ── Scan accent ──────────────────────────────
  static const Color scanAccent = Color(0xFF00D4D4);

  // ── Legacy aliases still referenced ──────────
  static const Color background    = pageBackground;
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color error         = danger;
  static const Color textMuted     = textSecondary;
  static const Color bgPrimary     = pageBackground;
  static const Color bgCard        = surface;
  static const double cardRadius   = 24.0;
  static const double chipRadius   = 50.0;
  static List<BoxShadow> get cardShadow => md;
  static List<BoxShadow> get softShadow => md;
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryDark],
  );
  static const BoxShadow cyanGlow =
      BoxShadow(color: Color(0x4D2D7DD2), blurRadius: 20, offset: Offset(0, 4));
  static const BoxShadow cyanGlowStrong =
      BoxShadow(color: Color(0x662D7DD2), blurRadius: 30, offset: Offset(0, 6));
}
