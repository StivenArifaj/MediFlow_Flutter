import 'package:flutter/material.dart';

/// MediFlow — Futuristic "Space Meets Healthcare" Palette
class AppColors {
  AppColors._();

  // ── BACKGROUNDS ────────────────────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFF08090F); // Near-black deep space
  static const Color bgDark      = Color(0xFF08090F); // Alias for bgPrimary
  static const Color bgCard      = Color(0xFF0D1520); // Slightly lighter card bg
  static const Color bgCardGlass = Color(0x0DFFFFFF); // 5 % white — glassmorphism
  static const Color bgCardLight = Color(0xFF162032); // Elevated card / chip bg
  static const Color bgInput     = Color(0xFF111927); // Input field bg

  // ── BACKGROUND (Light Mode — kept for compatibility) ───────────────────
  static const Color bgLight       = Color(0xFFF0FAFA);
  static const Color bgCardLight_lm = Color(0xFFFFFFFF);
  static const Color bgCardMid_lm  = Color(0xFFF5FAFA);

  // ── NEON PRIMARY ───────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF00E5FF); // Neon cyan
  static const Color primaryDark   = Color(0xFF00B8CC); // Darker for gradients
  static const Color neonCyan      = Color(0xFF00E5FF);
  static const Color neonCyanDark  = Color(0xFF00B8CC);
  static const Color neonCyanGlow  = Color(0x4D00E5FF); // 30 % cyan glow

  // ── TEXT ────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFF8A9BB5);
  static const Color textMuted      = Color(0xFF4A5A72);
  static const Color textPrimary_lm = Color(0xFF0D1B2A);
  static const Color textSecondary_lm = Color(0xFF5A7A96);

  // ── STATUS ─────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF00C896);
  static const Color warning  = Color(0xFFFFB800);
  static const Color error    = Color(0xFFFF3B5C);
  static const Color info     = Color(0xFF6B7FCC);

  // Dose-status aliases
  static const Color statusPending = Color(0xFFFFB800);
  static const Color statusTaken   = Color(0xFF00E5FF);
  static const Color statusMissed  = Color(0xFFFF3B5C);
  static const Color statusSkipped = Color(0xFF6B7FCC);

  // ── PREMIUM ────────────────────────────────────────────────────────────
  static const Color premiumFrom = Color(0xFF8B5CF6);
  static const Color premiumTo   = Color(0xFFEC4899);

  // ── CAREGIVER ACCENT ───────────────────────────────────────────────────
  static const Color caregiverAccent = Color(0xFF6366F1);

  // ── GRADIENTS ──────────────────────────────────────────────────────────

  /// Header / Subtle BG gradient (radial used in code, linear fallback here)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D1A2A), Color(0xFF08090F)],
  );

  /// Primary accent button gradient (cyan → blue)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00E5FF), Color(0xFF0080FF)],
  );

  /// Premium purple-to-pink
  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    transform: GradientRotation(2.356),
  );

  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF00C896), Color(0xFF00E5FF)],
  );

  /// Health-Tip gradient (green → cyan)
  static const LinearGradient tipGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00C896), Color(0xFF00E5FF)],
    transform: GradientRotation(2.356),
  );

  /// Radial background used on every screen
  static const RadialGradient spaceBg = RadialGradient(
    center: Alignment(0, -0.5),
    radius: 1.2,
    colors: [Color(0xFF0D1A2A), Color(0xFF08090F)],
  );

  // ── CARD DECORATIONS (helpers) ─────────────────────────────────────────

  static BoxDecoration get neonCardDecoration => BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1A00E5FF), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A00E5FF),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get glassCardDecoration => BoxDecoration(
        color: bgCardGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
      );

  // ── GLOW SHADOWS ───────────────────────────────────────────────────────

  static const BoxShadow cyanGlow = BoxShadow(
    color: Color(0x4D00E5FF),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static const BoxShadow cyanGlowStrong = BoxShadow(
    color: Color(0x6600E5FF),
    blurRadius: 30,
    offset: Offset(0, 6),
  );
}
