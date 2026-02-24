import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism card — 5 % white fill, blurred backdrop, subtle border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.blur = 10,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x0DFFFFFF), // 5 % white
            border: Border.all(color: const Color(0x1AFFFFFF)), // 10 % white
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Standard neon-bordered card — dark fill with cyan glow.
class NeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1826),
        border: Border.all(color: const Color(0x1A00E5FF)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1200E5FF),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
