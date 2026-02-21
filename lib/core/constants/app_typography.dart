import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MediFlow Typography System
/// Uses Inter font from Google Fonts
class AppTypography {
  AppTypography._();

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

  // Display Styles
  static TextStyle displayLarge({Color? color}) => _baseStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle displayMedium({Color? color}) => _baseStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: color,
      );

  // Headline Styles
  static TextStyle headlineLarge({Color? color}) => _baseStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static TextStyle headlineMedium({Color? color}) => _baseStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // Title Styles
  static TextStyle titleLarge({Color? color}) => _baseStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle titleMedium({Color? color}) => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      );

  // Body Styles
  static TextStyle bodyLarge({Color? color}) => _baseStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      );

  static TextStyle bodyMedium({Color? color}) => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle bodySmall({Color? color}) => _baseStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: color ?? AppColors.textSecondary,
      );

  // Label Styles
  static TextStyle labelLarge({Color? color}) => _baseStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );
}
