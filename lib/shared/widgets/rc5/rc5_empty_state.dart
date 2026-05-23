import 'package:flutter/material.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/shared/widgets/rc5/rc5_button.dart';
import 'package:grow/shared/widgets/rc5/rc5_card.dart';

class RC5EmptyState extends StatelessWidget {
  const RC5EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      shadowOpacity: 0.7,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: RC5DesignTokens.softGradient,
              borderRadius: BorderRadius.circular(RC5DesignTokens.radiusLg),
              border: Border.all(
                color: RC5DesignTokens.border,
                width: RC5DesignTokens.borderWidth,
              ),
            ),
            child: Icon(icon, color: RC5DesignTokens.primary, size: 28),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: RC5DesignTokens.space2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RC5DesignTokens.textSecondary,
                ),
          ),
          if (primaryActionLabel != null && onPrimaryAction != null) ...[
            const SizedBox(height: RC5DesignTokens.space5),
            RC5Button(
              label: primaryActionLabel!,
              onPressed: onPrimaryAction,
              fullWidth: true,
            ),
          ],
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: RC5DesignTokens.space3),
            RC5Button(
              label: secondaryActionLabel!,
              onPressed: onSecondaryAction,
              variant: RC5ButtonVariant.ghost,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }
}
