import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Neobrutalist card — the core container widget for Grow~.
/// Refined with premium soft shadows and dynamic borders.
class NeoCard extends StatefulWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.borderColor = AppColors.navy,
    this.shadowOffset,
    this.padding = const EdgeInsets.all(AppSizes.md),
    this.borderRadius = AppSizes.radiusMd,
    this.borderWidth = AppSizes.borderWidth,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Offset? shadowOffset;
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final offset = widget.shadowOffset ?? const Offset(0, 4);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
            color: widget.borderColor.withValues(alpha: 0.15),
            width: widget.borderWidth),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.08),
            offset: offset,
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          HapticFeedback.lightImpact();
          widget.onTap!();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: card.animate(target: _isPressed ? 1 : 0).scaleXY(
            begin: 1.0, end: 0.97, duration: 100.ms, curve: Curves.easeInOut),
      );
    }
    return card;
  }
}
