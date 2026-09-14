import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';

class RC5Badge extends StatelessWidget {
  const RC5Badge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? RC5DesignTokens.ink;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? RC5DesignTokens.space3 : RC5DesignTokens.space4,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
        border: Border.all(
          color: effectiveColor,
          width: RC5DesignTokens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: effectiveColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
