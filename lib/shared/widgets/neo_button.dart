import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        if (!widget.isLoading && widget.onPressed != null) {
          HapticFeedback.lightImpact();
          widget.onPressed!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.onPressed == null
              ? widget.color.withValues(alpha: 0.5)
              : widget.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: widget.borderColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy,
              offset: _isPressed ? const Offset(0, 0) : const Offset(4, 4),
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.textColor,
                    ),
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: widget.fontSize,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor,
                          ),
                    ),
                  ],
                ),
        ),
      ).animate(target: _isPressed ? 1 : 0).scaleXY(
          begin: 1.0, end: 0.95, duration: 100.ms, curve: Curves.easeInOut),
    );
  }
}
