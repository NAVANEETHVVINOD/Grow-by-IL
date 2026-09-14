import 'package:flutter/material.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

/// Opt-in RC5 theme for the Grow redesign.
///
/// The app can keep using [AppTheme] until each RC5 vertical slice is ready.
class RC5Theme {
  RC5Theme._();

  static const _headlineFamily = 'SpaceGrotesk';
  static const _bodyFamily = 'DMSans';
  static const _fallback = ['Roboto', 'sans-serif'];

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: RC5DesignTokens.background,
      colorScheme: const ColorScheme.light(
        primary: RC5DesignTokens.ink,
        onPrimary: Colors.white,
        secondary: RC5DesignTokens.accent,
        onSecondary: Colors.white,
        surface: RC5DesignTokens.surface,
        onSurface: RC5DesignTokens.ink,
        error: RC5DesignTokens.error,
        onError: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: RC5DesignTokens.ink,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RC5DesignTokens.ink;
          }
          return RC5DesignTokens.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return RC5DesignTokens.ink.withValues(alpha: 0.3);
          }
          return RC5DesignTokens.neutralSurface;
        }),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: RC5DesignTokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: RC5DesignTokens.ink,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        displayMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        displaySmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        headlineLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w800,
          color: RC5DesignTokens.ink,
        ),
        headlineMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        headlineSmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleLarge: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        titleSmall: TextStyle(
          fontFamily: _headlineFamily,
          fontFamilyFallback: _fallback,
          fontWeight: FontWeight.w700,
          color: RC5DesignTokens.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: RC5DesignTokens.ink,
          height: 1.35,
        ),
        bodyMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: RC5DesignTokens.ink,
          height: 1.35,
        ),
        bodySmall: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: RC5DesignTokens.textSecondary,
          height: 1.35,
        ),
        labelLarge: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: RC5DesignTokens.ink,
          fontWeight: FontWeight.w700,
        ),
        labelMedium: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
          color: RC5DesignTokens.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          fontFamily: _bodyFamily,
          fontFamilyFallback: _fallback,
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
            color: RC5DesignTokens.ink,
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
