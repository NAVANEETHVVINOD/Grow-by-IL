import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:grow/features/notifications/domain/notification_providers.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/core/constants/app_strings.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/shimmer_skeleton.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(activeEventsProvider);
            ref.invalidate(userProjectsProvider);
            ref.invalidate(activeSessionProvider);
            ref.invalidate(activeBookingProvider);
            ref.invalidate(currentUserProvider);
          },
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, ref),
                  // const SizedBox(height: AppSizes.lg),
                  // _buildSearchBar(context, ref), // REMOVED: fake search
                  const SizedBox(height: AppSizes.lg),
                  _buildLiveStatus(ref),
                  const SizedBox(height: AppSizes.lg),
                  _buildActionGrid(context, ref),
                  const SizedBox(height: AppSizes.xxl),
                  _buildSectionHeader('Your Schedule'),
                  const SizedBox(height: AppSizes.md),
                  _buildUpcomingSchedule(ref),
                  const SizedBox(height: AppSizes.xxl),
                  _buildSectionHeader(
                    'Active Projects',
                    onAction: () => context.go('/profile'),
                    actionLabel: 'VIEW ALL',
                  ),
                  const SizedBox(height: AppSizes.md),
                  _buildActiveProjects(ref),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatus(WidgetRef ref) {
    final sessionAsync = ref.watch(activeSessionProvider);
    final bookingAsync = ref.watch(activeBookingProvider);

    return Column(
      children: [
        sessionAsync.when(
          data: (session) {
            if (session == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.md),
              child: NeoCard(
                color: AppColors.green.withValues(alpha: 0.1),
                borderColor: AppColors.green,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Row(
                    children: [
                      const Icon(Icons.sensors_rounded, color: AppColors.green),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live in Lab',
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                color: AppColors.green,
                              ),
                            ),
                            Text(
                              'Checked in at ${session.checkinTime?.toLocal().toString().substring(11, 16) ?? "--:--"}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
                onTap: () => context.go('/lab'),
              ),
            );
          },
          loading: () =>
              const ShimmerSkeleton(width: double.infinity, height: 70),
          error: (_, __) => const SizedBox.shrink(),
        ),
        bookingAsync.when(
          data: (booking) {
            if (booking == null) return const SizedBox.shrink();
            return NeoCard(
              color: AppColors.cobalt.withValues(alpha: 0.1),
              borderColor: AppColors.cobalt,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.cobalt,
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Booking',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.bold,
                              color: AppColors.cobalt,
                            ),
                          ),
                          Text(
                            'Machine usage until ${booking.slotEnd.toLocal().toString().substring(11, 16)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.cobalt,
                    ),
                  ],
                ),
              ),
              onTap: () => context.push('/tools'),
            );
          },
          loading: () =>
              const ShimmerSkeleton(width: double.infinity, height: 70),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.yellow,
              radius: 24,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.name.split(' ').first}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    'Level ${user.level} \u2022 ${user.xp} XP',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, size: 28),
                  color: AppColors.navy,
                  onPressed: () => context.push('/notifications'),
                ),
                ref.watch(unreadNotificationCountProvider) > 0
                    ? Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${ref.watch(unreadNotificationCountProvider)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            if ([
              'admin',
              'operation_head',
              'machine_head',
              'super_admin'
            ].contains(user.role))
              IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined, size: 28),
                color: AppColors.cobalt,
                onPressed: () => context.push('/admin'),
              ),
          ],
        );
      },
      loading: () => Row(
        children: [
          const ShimmerSkeleton(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerSkeleton(width: 150, height: 24),
              SizedBox(height: 6),
              ShimmerSkeleton(width: 100, height: 14),
            ],
          ),
        ],
      ),
      error: (err, stack) => Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 28),
          const SizedBox(width: AppSizes.sm),
          const Text('Error loading profile'),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.md,
      mainAxisSpacing: AppSizes.md,
      childAspectRatio: 1.1,
      children: [
        _ActionTile(
          title: AppStrings.checkIn,
          subtitle: _buildVisitorCount(ref),
          icon: Icons.qr_code_scanner_rounded,
          color: AppColors.yellow,
          onTap: () => context.go('/lab'),
        ),
        _ActionTile(
          title: AppStrings.bookTool,
          subtitle: const Text(
            'Reserve equipment',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          icon: Icons.build_rounded,
          color: AppColors.cobalt,
          iconColor: Colors.white,
          textColor: Colors.white,
          onTap: () => context.push('/tools'),
        ),
        if (ref.watch(userProjectsProvider).valueOrNull?.isNotEmpty ?? false)
          _ActionTile(
            title: AppStrings.myProjects,
            subtitle: Text(
              'Manage builds',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: AppColors.navy.withValues(alpha: 0.6),
              ),
            ),
            icon: Icons.rocket_launch_rounded,
            color: Colors.white,
            onTap: () => context.push('/projects'),
          ),
      ],
    );
  }

  Widget _buildVisitorCount(WidgetRef ref) {
    final liveCount = ref.watch(liveLabVisitorCountProvider);
    return liveCount.when(
      data: (count) => Text(
        '$count ${AppStrings.activeNow}',
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.navy.withValues(alpha: 0.7),
        ),
      ),
      loading: () => const ShimmerSkeleton(width: 60, height: 14),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.yellow,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        const Spacer(),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel ?? 'VIEW ALL',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.cobalt,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingSchedule(WidgetRef ref) {
    final eventsAsync = ref.watch(activeEventsProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);

    return Column(
      children: [
        eventsAsync.when(
          data: (events) {
            final upcomingEvents = events.take(2).toList();
            if (upcomingEvents.isEmpty) return const SizedBox.shrink();
            return Column(
              children: upcomingEvents
                  .map(
                    (e) => _ScheduleItem(
                      title: e.title,
                      time: e.eventDate.toLocal().toString().substring(5, 16),
                      icon: Icons.event_available_rounded,
                      color: AppColors.yellow,
                      onTap: () => context.push('/events/${e.id}'),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () =>
              const ShimmerSkeleton(width: double.infinity, height: 60),
          error: (_, __) => const SizedBox.shrink(),
        ),
        bookingsAsync.when(
          data: (bookings) {
            final now = DateTime.now().toUtc();
            final futureBookings = bookings
                .where(
                  (b) => b.slotStart.isAfter(now) && b.status == 'approved',
                )
                .take(2)
                .toList();
            if (futureBookings.isEmpty) return const SizedBox.shrink();
            return Column(
              children: futureBookings
                  .map(
                    (b) => _ScheduleItem(
                      title: 'Equipment Booking',
                      time: b.slotStart.toLocal().toString().substring(5, 16),
                      icon: Icons.precision_manufacturing_rounded,
                      color: AppColors.cobalt,
                      iconColor: Colors.white,
                      onTap: () => context.push('/tools'),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () =>
              const ShimmerSkeleton(width: double.infinity, height: 60),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildActiveProjects(WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsProvider);

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return NeoCard(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_open_rounded,
                    color: AppColors.textSecondary,
                    size: 32,
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      AppStrings.noActiveProjects,
                      style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) {
            final project = projects[index];
            return NeoCard(
              color: Colors.white,
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.navy, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const Icon(
                        Icons.architecture_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.navy,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            project.visibility.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              onTap: () => context.push('/projects/${project.id}'),
            );
          },
        );
      },
      loading: () => Column(
        children: List.generate(
          2,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSizes.sm),
            child: ShimmerSkeleton(width: double.infinity, height: 72),
          ),
        ),
      ),
      error: (err, stack) => NeoCard(
        color: AppColors.red.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.red),
              const SizedBox(width: AppSizes.sm),
              const Expanded(
                child: Text(
                  'Something went wrong',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated action tile with scale-on-press effect.
class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.textColor = AppColors.navy,
    this.iconColor = AppColors.navy,
  });

  final String title;
  final Widget subtitle;
  final IconData icon;
  final Color color;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: NeoCard(
          color: widget.color,
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(widget.icon, size: 32, color: widget.iconColor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                  ),
                  widget.subtitle,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({
    required this.title,
    required this.time,
    required this.icon,
    required this.color,
    this.iconColor = AppColors.navy,
    required this.onTap,
  });

  final String title;
  final String time;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: NeoCard(
        color: Colors.white,
        padding: const EdgeInsets.all(AppSizes.md),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.navy, width: 1.5),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    time,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
