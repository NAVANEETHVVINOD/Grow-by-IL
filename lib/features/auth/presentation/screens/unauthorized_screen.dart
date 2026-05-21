import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/neo_button.dart';
import '../../../../shared/widgets/neo_card.dart';

/// Premium Neobrutalist Unauthorized Screen.
/// Shown when a user attempts to access restricted areas (e.g. Admin Panel) without proper roles.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Lock Icon Container with Staggered Entrance
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.red, width: 3),
                    ),
                    child: const Icon(
                      Icons.gpp_bad_rounded,
                      size: 64,
                      color: AppColors.red,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, curve: Curves.easeOutCubic)
                      .scaleXY(
                          begin: 0.7,
                          end: 1.0,
                          duration: 500.ms,
                          curve: Curves.elasticOut),

                  const SizedBox(height: AppSizes.xl),

                  // Text Warning Box
                  NeoCard(
                    color: Colors.white,
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      children: [
                        Text(
                          'Access Denied',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.navy,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.md),
                        Text(
                          'You do not have the required permissions to view this section. This page is restricted to lab administrators and operational heads.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSizes.xl),

                  // Return Home Action Button
                  NeoButton(
                    label: 'Return to Safety',
                    icon: Icons.home_rounded,
                    onPressed: () => context.go('/home'),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0.0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
