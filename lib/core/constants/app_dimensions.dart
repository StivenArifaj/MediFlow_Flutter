import 'package:flutter/material.dart';

/// MediFlow Spacing, Radius, and Shadow Constants — Futuristic Edition
class AppDimensions {
  AppDimensions._();

  // SPACING
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // BORDER RADIUS
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // SHADOWS
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x26000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x33000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowTeal = BoxShadow(
    color: Color(0x4D00E5FF),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  // COMPONENT SIZES
  static const double buttonHeight = 52.0;
  static const double fabSize = 60.0;
  static const double cardPadding = 16.0;
  static const double inputPadding = 16.0;
}
