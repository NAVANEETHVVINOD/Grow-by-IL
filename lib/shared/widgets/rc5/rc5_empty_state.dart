import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';
import 'rc5_card.dart';
import 'rc5_button.dart';

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
    this.accentColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? RC5DesignTokens.accent;

    return Semantics(
      container: true,
      label: 'Empty state: $title. $message',
      child: RC5Card(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        radius: 20,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: effectiveAccentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: RC5DesignTokens.border,
                    width: RC5DesignTokens.borderWidth,
                  ),
                ),
                child: Icon(
                  icon,
                  color: effectiveAccentColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: RC5DesignTokens.cardTitle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: RC5DesignTokens.body.copyWith(
                  color: RC5DesignTokens.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (primaryActionLabel != null && onPrimaryAction != null) ...[
                const SizedBox(height: 20),
                RC5Button(
                  label: primaryActionLabel!,
                  onPressed: onPrimaryAction,
                  variant: RC5ButtonVariant.primary,
                  fullWidth: true,
                ),
              ],
              if (secondaryActionLabel != null &&
                  onSecondaryAction != null) ...[
                const SizedBox(height: 10),
                RC5Button(
                  label: secondaryActionLabel!,
                  onPressed: onSecondaryAction,
                  variant: RC5ButtonVariant.ghost,
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
