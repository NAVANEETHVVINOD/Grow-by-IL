import 'package:flutter/material.dart';

/// Grow~ Neobrutalist color palette.
///
/// Design language: bold, high-contrast, maker-culture aesthetic.
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const background = Color(0xFFF8F7F4); // cream background
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF111111); // black

  // ── Primary palette ──────────────────────────────────────
  static const yellow = Color(0xFFF7EEB4); // pastel yellow
  static const navy = Color(0xFF111111); // primary black
  static const cobalt = Color(0xFFDFF4FF); // pastel blue
  static const green = Color(0xFFDDF5D7); // pastel green
  static const red = Color(0xFFEF4444); // soft red
  static const orange = Color(0xFFF7EEB4); // pastel yellow fallback

  // ── Text ─────────────────────────────────────────────────
  static const textPrimary = Color(0xFF111111);
  static const textSecondary = Color(0xFF71717A);
  static const textOnDark = Color(0xFFF8F7F4);
  static const textOnYellow = Color(0xFF111111);

  // ── Neobrutalist shadows (flat, no blur) ─────────────────
  static const shadowOffset = Offset(4, 4);
  static const shadowColor = Color(0xFF0D0F1C);

  // ── Status chips ─────────────────────────────────────────
  static const available = Color(0xFF2ECC71);
  static const inUse = Color(0xFFFF3B3B);
  static const pending = Color(0xFFFF6B35);
  static const maintenance = Color(0xFF9B59B6);
}
