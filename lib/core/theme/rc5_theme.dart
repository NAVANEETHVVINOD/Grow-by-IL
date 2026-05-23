import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

/// Opt-in RC5 theme for the Grow redesign.
///
/// The app can keep using [AppTheme] until each RC5 vertical slice is ready.
class RC5Theme {
  RC5Theme._();

  static ThemeData get light {
    final headlineFont = GoogleFonts.spaceGroteskTextTheme();
    final bodyFont = GoogleFonts.dmSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: RC5DesignTokens.background,
      colorScheme: const ColorScheme.light(
        primary: RC5DesignTokens.primary,
        onPrimary: Colors.white,
        secondary: RC5DesignTokens.accent,
        onSecondary: Colors.white,
        surface: RC5DesignTokens.surface,
        onSurface: RC5DesignTokens.ink,
        error: RC5DesignTokens.error,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: RC5DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: RC5DesignTokens.ink,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: headlineFont.displayLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        displayMedium: headlineFont.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        displaySmall: headlineFont.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        headlineLarge: headlineFont.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        headlineMedium: headlineFont.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        headlineSmall: headlineFont.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleLarge: headlineFont.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleMedium: headlineFont.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleSmall: headlineFont.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        bodyLarge: bodyFont.bodyLarge?.copyWith(
          color: RC5DesignTokens.ink,
          height: 1.35,
        ),
        bodyMedium: bodyFont.bodyMedium?.copyWith(
          color: RC5DesignTokens.ink,
          height: 1.35,
        ),
        bodySmall: bodyFont.bodySmall?.copyWith(
          color: RC5DesignTokens.textSecondary,
          height: 1.35,
        ),
        labelLarge: bodyFont.labelLarge?.copyWith(
          color: RC5DesignTokens.ink,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: bodyFont.labelMedium?.copyWith(
          color: RC5DesignTokens.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: bodyFont.labelSmall?.copyWith(
          color: RC5DesignTokens.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: RC5DesignTokens.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: RC5DesignTokens.space4,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: RC5DesignTokens.border,
            width: RC5DesignTokens.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: RC5DesignTokens.border,
            width: RC5DesignTokens.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: RC5DesignTokens.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
          borderSide: const BorderSide(
            color: RC5DesignTokens.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}
