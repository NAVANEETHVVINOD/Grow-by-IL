import 'package:flutter/material.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

class RC5Chip extends StatelessWidget {
  const RC5Chip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.color,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selectedColor = color ?? RC5DesignTokens.ink;
    final background = isSelected ? selectedColor : RC5DesignTokens.surfaceAlt;
    final foreground = isSelected ? Colors.white : RC5DesignTokens.ink;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
        child: AnimatedContainer(
          duration: RC5DesignTokens.motionBase,
          curve: RC5DesignTokens.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal:
                compact ? RC5DesignTokens.space3 : RC5DesignTokens.space4,
            vertical: compact ? RC5DesignTokens.space2 : RC5DesignTokens.space3,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
            border: Border.all(
              color: isSelected ? selectedColor : RC5DesignTokens.border,
              width: RC5DesignTokens.borderWidth,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 15 : 17, color: foreground),
                const SizedBox(width: RC5DesignTokens.space2),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
