import 'package:flutter/material.dart';

/// Grow~ Neobrutalist color palette.
///
/// Design language: bold, high-contrast, maker-culture aesthetic.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const background = Color(0xFFF5F5F0); // warm off-white
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF0D0F1C); // deep navy

  // ── Primary palette ──────────────────────────────────────
  static const yellow = Color(0xFFFFD60A); // electric yellow (primary accent)
  static const navy = Color(0xFF0D0F1C); // primary dark
  static const cobalt = Color(0xFF1A56FF); // blue accent
  static const green = Color(0xFF2ECC71); // available / success
  static const red = Color(0xFFFF3B3B); // error / in-use
  static const orange = Color(0xFFFF6B35); // warning

  // ── Text ─────────────────────────────────────────────────
  static const textPrimary = Color(0xFF0D0F1C);
  static const textSecondary = Color(0xFF4A4A5A);
  static const textOnDark = Color(0xFFF5F5F0);
  static const textOnYellow = Color(0xFF0D0F1C);

  // ── Neobrutalist shadows (flat, no blur) ─────────────────
  static const shadowOffset = Offset(4, 4);
  static const shadowColor = Color(0xFF0D0F1C);

  // ── Status chips ─────────────────────────────────────────
  static const available = Color(0xFF2ECC71);
  static const inUse = Color(0xFFFF3B3B);
  static const pending = Color(0xFFFF6B35);
  static const maintenance = Color(0xFF9B59B6);
}
