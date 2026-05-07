import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact neobrutalist status chip / badge.
///
/// Automatically picks dark or light text based on background luminance.
class NeoChip extends StatelessWidget {
  const NeoChip({
    super.key,
    required this.label,
    required this.color,
    this.height = 28,
    this.horizontalPadding = 12,
    this.borderRadius = 6,
  });

  final String label;
  final Color color;
  final double height;
  final double horizontalPadding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // Pick text colour based on background brightness
    final textColor = color.computeLuminance() > 0.5
        ? const Color(0xFF0D0F1C)
        : const Color(0xFFF5F5F0);

    // Border colour is a slightly darker version of the chip colour
    final borderColor = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0),
        )
        .toColor();

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1,
          ),
        ),
      ),
    );
  }
}
