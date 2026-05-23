import 'package:flutter/material.dart';

/// RC5 visual tokens for Grow's soft neo-brutalist redesign.
///
/// These tokens are intentionally separate from the existing RC4 theme so the
/// redesign can be adopted section by section without destabilizing live flows.
class RC5DesignTokens {
  RC5DesignTokens._();

  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F7FF);
  static const surfaceAlt = Color(0xFFF3F4F6);
  static const ink = Color(0xFF09090B);
  static const textSecondary = Color(0xFF71717A);
  static const border = Color(0xFFE4E4E7);
  static const primary = Color(0xFF7C3AED);
  static const primaryEnd = Color(0xFFA855F7);
  static const accent = Color(0xFFEC4899);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const muted = Color(0xFFA1A1AA);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryEnd, accent],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F7FF), Color(0xFFFFF1F7)],
  );

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusPill = 999;

  static const double borderWidth = 1.5;
  static const Offset shadowOffset = Offset(3, 3);

  static const Duration motionFast = Duration(milliseconds: 120);
  static const Duration motionBase = Duration(milliseconds: 200);
  static const Duration motionSlow = Duration(milliseconds: 300);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  static List<BoxShadow> neoShadow({
    Color color = ink,
    double opacity = 1,
    Offset offset = shadowOffset,
  }) {
    return [
      BoxShadow(
        color: color.withValues(alpha: opacity),
        offset: offset,
        blurRadius: 0,
      ),
    ];
  }
}
