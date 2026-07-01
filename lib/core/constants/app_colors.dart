import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── NEW LIGHT PALETTE ─────────────────────────────────────────────────────

  // Backgrounds
  static const Color background     = Color(0xFFF8FAFB);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  // Primary — trustworthy blue
  static const Color primary        = Color(0xFF2D7DD2);
  static const Color primaryLight   = Color(0xFFEBF4FF);
  static const Color primaryDark    = Color(0xFF1A5BA8);

  // Status
  static const Color success        = Color(0xFF27AE60);
  static const Color successLight   = Color(0xFFE8F8EF);
  static const Color warning        = Color(0xFFF39C12);
  static const Color warningLight   = Color(0xFFFFF8E8);
  static const Color danger         = Color(0xFFE74C3C);
  static const Color dangerLight    = Color(0xFFFFEBE9);

  // Caregiver accent — warm indigo
  static const Color caregiver      = Color(0xFF5B6EF5);
  static const Color caregiverLight = Color(0xFFEEF0FF);

  // Linked patient accent — warm amber
  static const Color linked         = Color(0xFFF5A623);
  static const Color linkedLight    = Color(0xFFFFF3E0);

  // Text
  static const Color textPrimary    = Color(0xFF1A2332);
  static const Color textSecondary  = Color(0xFF6B7C93);
  static const Color textTertiary   = Color(0xFF9BABBF);
  static const Color textOnPrimary  = Color(0xFFFFFFFF);

  // Borders / dividers
  static const Color border         = Color(0xFFE8ECF0);
  static const Color divider        = Color(0xFFF0F4F8);

  // ── LEGACY ALIASES (keep for non-auth screens during redesign) ───────────

  static const Color bgPrimary      = Color(0xFF08090F);
  static const Color bgDark         = Color(0xFF08090F);
  static const Color bgCard         = Color(0xFF0D1520);
  static const Color bgCardGlass    = Color(0x0DFFFFFF);
  static const Color bgCardLight    = Color(0xFF162032);
  static const Color bgInput        = Color(0xFF111927);
  static const Color bgLight        = Color(0xFFF0FAFA);
  static const Color bgCardLight_lm = Color(0xFFFFFFFF);
  static const Color bgCardMid_lm   = Color(0xFFF5FAFA);

  // Camera scan UI accent — visible on dark camera background
  static const Color scanAccent     = Color(0xFF00D4D4);

  static const Color info           = Color(0xFF2D7DD2); // was 0xFF6B7FCC
  static const Color premiumFrom    = Color(0xFF8B5CF6);
  static const Color premiumTo      = Color(0xFFEC4899);
  static const Color neonCyanDark   = Color(0xFF00B8CC);
  static const Color caregiverAccent = Color(0xFF5B6EF5);

  static const Color textPrimary_lm    = Color(0xFF1A2332);
  static const Color textSecondary_lm  = Color(0xFF6B7C93);
  static const Color textMuted         = Color(0xFF4A5A72);
  static const Color error             = Color(0xFFE74C3C);

  static const Color statusPending  = Color(0xFFF39C12);
  static const Color statusTaken    = Color(0xFF2D7DD2);
  static const Color statusMissed   = Color(0xFFE74C3C);
  static const Color statusSkipped  = Color(0xFF5B6EF5);

  // Dark theme values for future use
  static const Color darkBackground = Color(0xFF0D1B2A);
  static const Color darkSurface    = Color(0xFF162032);

  // ── GRADIENTS ─────────────────────────────────────────────────────────────

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1A2A), Color(0xFF08090F)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF2D7DD2), Color(0xFF1A5BA8)],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    transform: GradientRotation(2.356),
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF27AE60), Color(0xFF2D7DD2)],
  );

  static const LinearGradient tipGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF27AE60), Color(0xFF2D7DD2)],
    transform: GradientRotation(2.356),
  );

  static const RadialGradient spaceBg = RadialGradient(
    center: Alignment(0, -0.5),
    radius: 1.2,
    colors: [Color(0xFF0D1A2A), Color(0xFF08090F)],
  );

  // ── GLOW SHADOWS (kept for compatibility) ─────────────────────────────────

  static const BoxShadow cyanGlow = BoxShadow(
    color: Color(0x4D2D7DD2),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow cyanGlowStrong = BoxShadow(
    color: Color(0x662D7DD2),
    blurRadius: 30,
    offset: Offset(0, 6),
  );

  // ── THEME-AWARE HELPERS ───────────────────────────────────────────────────

  static bool _dark(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark;

  static Color scaffoldBg(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF060E1B) : background;

  static Color cardBg(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF0D1826) : surface;

  static Color cardBorder(BuildContext ctx) =>
      _dark(ctx) ? const Color(0x1A2D7DD2) : border;

  static Color inputBg(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF111927) : surfaceVariant;

  static Color textH(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFFFFFFFF) : textPrimary;

  static Color textBody(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFFCDD8E8) : textPrimary;

  static Color textHint(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF4A5A72) : textTertiary;

  static Color textSub(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF8A9BB5) : textSecondary;

  static Color accent(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF00E5FF) : primary;

  static Color dividerColor(BuildContext ctx) =>
      _dark(ctx) ? const Color(0x1AFFFFFF) : border;

  static Color navBg(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF0A1520) : surface;

  static Color navSelected(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF00E5FF) : primary;

  static Color navUnselected(BuildContext ctx) =>
      _dark(ctx) ? const Color(0xFF4A5A72) : textTertiary;

  static List<BoxShadow> cardShadow(BuildContext ctx) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: _dark(ctx) ? 0.18 : 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static BoxDecoration cardDecoration(BuildContext ctx) => BoxDecoration(
    color: cardBg(ctx),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: cardBorder(ctx), width: 1),
    boxShadow: cardShadow(ctx),
  );
}
