import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_logger.dart';
import '../../features/lab/domain/lab_providers.dart';

/// Persistent shell that wraps the 5 main tabs with a neobrutalist bottom nav.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });

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
      AppLogger.info(LogCategory.SYSTEM, 'Heartbeat tick — checking session freshness');
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
    return Scaffold(
      body: widget.navigationShell,
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
