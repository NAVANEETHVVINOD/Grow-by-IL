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
    final offset = _isPressed
        ? const Offset(0, 0)
        : (widget.shadowOffset ?? const Offset(4, 4));

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth < 2 ? 3 : widget.borderWidth),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy,
            offset: offset,
            blurRadius: 0, // Hard shadow
            spreadRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return RepaintBoundary(
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap!();
          },
          child: card.animate(target: _isPressed ? 1 : 0).scaleXY(
              begin: 1.0, end: 0.97, duration: 100.ms, curve: Curves.easeInOut),
        ),
      );
    }
    return RepaintBoundary(child: card);
  }
}
