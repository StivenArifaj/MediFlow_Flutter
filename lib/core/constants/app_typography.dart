import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // ── NEW CONST STYLES (used by redesigned screens) ─────────────────────────

  static TextStyle get display => GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2);

  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.3);

  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3);

  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4);

  static TextStyle get bodyLargeStyle => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5);

  static TextStyle get body => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5);

  static TextStyle get bodySmallStyle => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5);

  static TextStyle get label => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary);

  static TextStyle get labelSmall => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary);

  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary);

  // ── LEGACY METHOD FORMS (keep for non-auth screens) ───────────────────────

  static TextStyle _baseStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
    );
  }

  static TextStyle displayLarge({Color? color}) => _baseStyle(
    fontSize: 32, fontWeight: FontWeight.bold, color: color);

  static TextStyle displayMedium({Color? color}) => _baseStyle(
    fontSize: 28, fontWeight: FontWeight.bold, color: color);

  static TextStyle headlineLarge({Color? color}) => _baseStyle(
    fontSize: 24, fontWeight: FontWeight.bold, color: color);

  static TextStyle headlineMedium({Color? color}) => _baseStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: color);

  static TextStyle titleLarge({Color? color}) => _baseStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: color);

  static TextStyle titleMedium({Color? color}) => _baseStyle(
    fontSize: 16, fontWeight: FontWeight.w500, color: color);

  static TextStyle bodyLarge({Color? color}) => _baseStyle(
    fontSize: 16, fontWeight: FontWeight.normal, color: color);

  static TextStyle bodyMedium({Color? color}) => _baseStyle(
    fontSize: 14, fontWeight: FontWeight.normal,
    color: color ?? AppColors.textSecondary);

  static TextStyle bodySmall({Color? color}) => _baseStyle(
    fontSize: 12, fontWeight: FontWeight.normal,
    color: color ?? AppColors.textSecondary);

  static TextStyle labelLarge({Color? color}) => _baseStyle(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: color ?? AppColors.primary);
}
