import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Neobrutalist card — the core container widget for Grow~.
///
/// Thick solid border, flat offset shadow, no blur.
class NeoCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final offset = shadowOffset ?? const Offset(AppSizes.shadowX, AppSizes.shadowY);

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            offset: offset,
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
