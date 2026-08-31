import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Grow~ Neobrutalist Material theme.
class AppTheme {
  AppTheme._();

  static const _headlineFamily = 'SpaceGrotesk';
  static const _bodyFamily = 'DMSans';
  static const _fallback = ['Roboto', 'sans-serif'];

  static ThemeData get light {
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.navy,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.navy,
        ),
      ),

      // ── Text theme ─────────────────────────────────────────
      textTheme: const TextTheme(
        // Display
        displayLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        // Headline
        headlineLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),

        // Title
        titleLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Body
        bodyLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textSecondary,
        ),

        // Label
        labelLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textSecondary,
        ),
      ),

      // ── Input decoration ───────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.navy.withValues(alpha: 0.2), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.navy.withValues(alpha: 0.2), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cobalt, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: AppColors.textSecondary,
        ),
      ),

      // ── Divider ────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.navy.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}
