import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grow/shared/widgets/neo_button.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/providers/toast_provider.dart';

import '../../features/notifications/domain/notification_providers.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_logger.dart';
import '../../features/lab/domain/lab_providers.dart';

IconData _getIconForType(String type) {
  switch (type) {
    case 'tool_booking_approved':
      return Icons.check_circle_rounded;
    case 'tool_booking_rejected':
      return Icons.cancel_rounded;
    case 'lab_checkin':
      return Icons.login_rounded;
    default:
      return Icons.notifications_rounded;
  }
}

Color _getColorForType(String type) {
  switch (type) {
    case 'tool_booking_approved':
      return AppColors.green;
    case 'tool_booking_rejected':
      return AppColors.red;
    case 'lab_checkin':
      return AppColors.yellow;
    default:
      return AppColors.navy;
  }
}

/// Persistent shell that wraps the 5 main tabs with a neobrutalist bottom nav.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late Timer _heartbeatTimer;

  @override
  void initState() {
    super.initState();
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      AppLogger.info(
        LogCategory.system,
        'Heartbeat tick — checking session freshness',
      );
      ref.read(labRepositoryProvider).refreshSession();
    });
  }

  @override
  void dispose() {
    _heartbeatTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new notifications to show Top Toasts
    ref.listen(notificationStreamProvider, (previous, next) {
      if (next is AsyncData && next.value!.isNotEmpty) {
        final newest = next.value!.first;
        // Only show if it's new (created in the last 10 seconds)
        if (newest.createdAt.isAfter(DateTime.now().subtract(const Duration(seconds: 10)))) {
          ref.read(toastProvider.notifier).show(
            title: newest.title,
            message: newest.message,
            icon: _getIconForType(newest.type),
            color: _getColorForType(newest.type),
          );
        }
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final currentIndex = widget.navigationShell.currentIndex;
        if (currentIndex != 0) {
          // Not on home tab → go to home tab
          widget.navigationShell.goBranch(0);
        } else {
          // On home tab → show exit dialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                side: const BorderSide(color: AppColors.navy, width: 2),
              ),
              title: const Text(
                'Exit Grow~?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text('Are you sure you want to exit?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                NeoButton(
                  label: 'Exit',
                  color: AppColors.red,
                  width: 100,
                  height: 40,
                  onPressed: () => SystemNavigator.pop(),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                final currentIndex = widget.navigationShell.currentIndex;
                if (details.primaryVelocity! < 0) {
                  // Swipe Left → Go Right
                  if (currentIndex < 4) {
                    widget.navigationShell.goBranch(currentIndex + 1);
                  }
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Right → Go Left
                  if (currentIndex > 0) {
                    widget.navigationShell.goBranch(currentIndex - 1);
                  }
                }
              },
              child: widget.navigationShell,
            ),
            // Top Toast System
            _TopToastOverlay(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              top: BorderSide(
                color: AppColors.navy,
                width: AppSizes.borderWidth,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: AppSizes.bottomNavHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: AppStrings.tabHome,
                    isSelected: widget.navigationShell.currentIndex == 0,
                    onTap: () => widget.navigationShell.goBranch(0),
                  ),
                  _NavItem(
                    icon: Icons.explore_rounded,
                    label: AppStrings.tabExplore,
                    isSelected: widget.navigationShell.currentIndex == 1,
                    onTap: () => widget.navigationShell.goBranch(1),
                  ),
                  _NavItem(
                    icon: Icons.calendar_month_rounded,
                    label: AppStrings.tabEvents,
                    isSelected: widget.navigationShell.currentIndex == 2,
                    onTap: () => widget.navigationShell.goBranch(2),
                  ),
                  _NavItem(
                    icon: Icons.science_rounded,
                    label: AppStrings.tabLab,
                    isSelected: widget.navigationShell.currentIndex == 3,
                    onTap: () => widget.navigationShell.goBranch(3),
                  ),
                  _NavItem(
                    icon: Icons.person_rounded,
                    label: AppStrings.tabProfile,
                    isSelected: widget.navigationShell.currentIndex == 4,
                    onTap: () => widget.navigationShell.goBranch(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.navy : AppColors.textSecondary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.navy : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopToastOverlay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(toastProvider);
    if (toast == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Dismissible(
          key: ValueKey(toast.title + DateTime.now().millisecondsSinceEpoch.toString()),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => ref.read(toastProvider.notifier).dismiss(),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: NeoCard(
              color: Colors.white,
              borderColor: toast.color,
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: toast.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(toast.icon, color: toast.color, size: 20),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toast.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.navy,
                          ),
                        ),
                        Text(
                          toast.message,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
