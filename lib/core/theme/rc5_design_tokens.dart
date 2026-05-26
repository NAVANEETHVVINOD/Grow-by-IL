import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// RC5 visual tokens for Grow's soft neo-brutalist redesign.
///
/// These tokens are intentionally separate from the existing RC4 theme so the
/// redesign can be adopted section by section without destabilizing live flows.
class RC5DesignTokens {
  RC5DesignTokens._();

  static const background = Color(0xFFFCFCFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFFFF7A1);
  static const ink = Color(0xFF111111);
  static const textSecondary = Color(0xFF71717A);
  static const border = Color(0xFF111111);
  static const primary = Color(0xFFF5D6F7);
  static const primaryEnd = Color(0xFFF5D6F7);
  static const accent = Color(0xFFDFF4FF);
  static const success = Color(0xFFDDF5D7);
  static const warning = Color(0xFFFFF7A1);
  static const error = Color(0xFFEF4444);
  static const muted = Color(0xFFA1A1AA);

  static const inkPrimary = Color(0xFF111111);
  static const neutralSurface = Color(0xFFF3F4F6);
  static const darkSurface = Color(0xFF3F3F46);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent, success],
  );

  static const monochromeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF111111), Color(0xFF2D2D2D)],
  );

  static const softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF3F4F6)],
  );

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  static const double radiusSm = 12;
  static const double radiusMd = 24;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  static const double borderWidth = 2.0;
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

  static TextStyle get hero => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w800,
        fontSize: 32,
        color: ink,
        letterSpacing: -1.0,
      );

  static TextStyle get sectionTitle => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: ink,
        letterSpacing: -0.5,
      );

  static TextStyle get cardTitle => GoogleFonts.spaceGrotesk(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        color: ink,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: ink,
        height: 1.4,
      );
}
