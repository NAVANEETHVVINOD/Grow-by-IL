import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/shared/widgets/neo_card.dart';

class NeoErrorWidget extends StatelessWidget {
  const NeoErrorWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred. Please try again later.',
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.isOffline = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final displayIcon = isOffline ? Icons.wifi_off_rounded : icon;
    final displayTitle = isOffline ? 'No Internet Connection' : title;
    final displayMessage = isOffline
        ? 'Please check your connection and tap the button below to retry.'
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: NeoCard(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.lg,
            vertical: AppSizes.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: (isOffline ? AppColors.cobalt : AppColors.red)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  displayIcon,
                  color: isOffline ? AppColors.cobalt : AppColors.red,
                  size: 48,
                ),
              ).animate().scale(
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: AppSizes.lg),

              // Title
              Text(
                displayTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // Message
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),

              if (onRetry != null) ...[
                const SizedBox(height: AppSizes.xl),
                NeoButton(
                  label: 'Try Again',
                  icon: Icons.refresh_rounded,
                  color: isOffline ? AppColors.cobalt : AppColors.yellow,
                  textColor: isOffline ? Colors.white : AppColors.navy,
                  onPressed: onRetry,
                  width: 160,
                  height: 44,
                ),
              ],
            ],
          ),
        ),
      ).animate().fade(duration: 200.ms).slideY(
            begin: 0.1,
            end: 0,
            duration: 200.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }
}
