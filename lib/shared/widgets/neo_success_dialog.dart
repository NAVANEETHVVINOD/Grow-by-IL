import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import 'neo_button.dart';
import 'neo_card.dart';

class NeoSuccessDialog extends StatelessWidget {
  const NeoSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'Awesome',
    this.onButtonPressed,
  });

  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Awesome',
    VoidCallback? onButtonPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: (value - 0.8) / 0.2, // Fade in with the scale
              child: child,
            ),
          );
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(AppSizes.lg),
          child: NeoSuccessDialog(
            title: title,
            message: message,
            buttonText: buttonText,
            onButtonPressed: onButtonPressed,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.navy, width: 2),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.navy,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          NeoButton(
            label: buttonText,
            color: AppColors.yellow,
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (onButtonPressed != null) {
                onButtonPressed!();
              }
            },
          ),
        ],
      ),
    );
  }
}
