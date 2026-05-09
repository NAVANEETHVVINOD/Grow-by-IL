import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Grow~ Neobrutalist Material theme.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final headlineFont = GoogleFonts.spaceGroteskTextTheme();
    final bodyFont = GoogleFonts.dmSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,

      // ── Color scheme ───────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: AppColors.yellow,
        onPrimary: AppColors.navy,
        secondary: AppColors.cobalt,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.navy,
        error: AppColors.red,
        onError: Colors.white,
      ),

      // ── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.navy,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),

      // ── Text theme ─────────────────────────────────────────
      textTheme: TextTheme(
        // Display
        displayLarge: headlineFont.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: headlineFont.displayMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: headlineFont.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        // Headline
        headlineLarge: headlineFont.headlineLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: headlineFont.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: headlineFont.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        // Title
        titleLarge: headlineFont.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: headlineFont.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: headlineFont.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Body
        bodyLarge: bodyFont.bodyLarge?.copyWith(color: AppColors.textPrimary),
        bodyMedium: bodyFont.bodyMedium?.copyWith(color: AppColors.textPrimary),
        bodySmall: bodyFont.bodySmall?.copyWith(color: AppColors.textSecondary),

        // Label
        labelLarge: bodyFont.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: bodyFont.labelMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelSmall: bodyFont.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),

      // ── Input decoration ───────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.yellow, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
        labelStyle: GoogleFonts.dmSans(color: AppColors.textSecondary),
      ),

      // ── Divider ────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.navy,
        thickness: 1.5,
      ),
    );
  }
}
