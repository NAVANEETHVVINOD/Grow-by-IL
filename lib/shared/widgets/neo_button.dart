import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Neobrutalist button with flat offset shadow.
///
/// Chunky, bold, and unmistakably tactile.
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.yellow,
    this.textColor = AppColors.navy,
    this.borderColor = AppColors.navy,
    this.width = double.infinity,
    this.height = AppSizes.buttonHeight,
    this.isLoading = false,
    this.icon,
    this.fontSize = 16,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double width;
  final double height;
  final bool isLoading;
  final IconData? icon;
  final double fontSize;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowOffset = _isPressed
        ? const Offset(1, 1)
        : const Offset(AppSizes.shadowX, AppSizes.shadowY);

    final translationOffset = _isPressed
        ? const Offset(3, 3)
        : Offset.zero;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading && widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Transform.translate(
        offset: translationOffset,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.onPressed == null
                ? widget.color.withValues(alpha: 0.5)
                : widget.color,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(
              color: widget.borderColor,
              width: AppSizes.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                offset: shadowOffset,
                blurRadius: 0,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: widget.textColor, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: widget.fontSize,
                          fontWeight: FontWeight.w700,
                          color: widget.textColor,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
