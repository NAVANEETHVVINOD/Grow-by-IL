import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_roles.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/auth/data/auth_repository.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/features/notifications/domain/notification_providers.dart';
import 'package:grow/features/projects/domain/project_providers.dart';
import 'package:grow/shared/models/booking_model.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/models/project_model.dart';
import 'package:grow/shared/models/user_model.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class RC5HomeScreen extends StatelessWidget {
  const RC5HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: RC5DesignTokens.primary,
          onRefresh: () async {
            final container = ProviderScope.containerOf(context);
            container.invalidate(currentUserProvider);
            container.invalidate(activeSessionProvider);
            container.invalidate(activeBookingProvider);
            container.invalidate(activeEventsProvider);
            container.invalidate(userProjectsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: const [
              HomeTopBar(),
              SizedBox(height: RC5DesignTokens.space5),
              LiveStatusStrip(),
              SizedBox(height: RC5DesignTokens.space5),
              QuickActionsGrid(),
              SizedBox(height: RC5DesignTokens.space6),
              UpcomingEventsCarousel(),
              SizedBox(height: RC5DesignTokens.space6),
              OpportunitiesPreview(),
              SizedBox(height: RC5DesignTokens.space6),
              MentorshipSupportPreview(),
              SizedBox(height: RC5DesignTokens.space6),
              ActiveProjectsPreview(),
              SizedBox(height: RC5DesignTokens.space6),
              KnowledgePreview(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const RC5Skeleton(width: double.infinity, height: 82);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: RC5Avatar(
                imageUrl: user.avatarUrl,
                displayName: user.name,
                size: 58,
              ),
            ),
            const SizedBox(width: RC5DesignTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${_firstName(user.name)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: RC5DesignTokens.ink,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _profileHandle(user),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RC5DesignTokens.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: RC5DesignTokens.space2),
                  Wrap(
                    spacing: RC5DesignTokens.space2,
                    runSpacing: RC5DesignTokens.space2,
                    children: [
                      RC5Chip(
                        label: 'Level ${user.level}',
                        icon: Icons.auto_awesome_rounded,
                        compact: true,
                        color: RC5DesignTokens.primary,
                        isSelected: true,
                      ),
                      RC5Chip(
                        label: '${user.xp} XP',
                        icon: Icons.bolt_rounded,
                        compact: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _IconBadgeButton(
              icon: Icons.notifications_outlined,
              count: unreadCount,
              onTap: () => context.push('/notifications'),
            ),
            if (AppRole.isAdminRole(user.role)) ...[
              const SizedBox(width: RC5DesignTokens.space2),
              _IconBadgeButton(
                icon: Icons.admin_panel_settings_outlined,
                onTap: () => context.push('/admin'),
              ),
            ],
          ],
        );
      },
      loading: () => const Row(
        children: [
          RC5Skeleton(width: 58, height: 58, radius: 29),
          SizedBox(width: RC5DesignTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RC5Skeleton(width: 170, height: 26),
                SizedBox(height: RC5DesignTokens.space2),
                RC5Skeleton(width: 120, height: 16),
              ],
            ),
          ),
        ],
      ),
      error: (_, __) => const RC5EmptyState(
        icon: Icons.person_off_rounded,
        title: 'Profile could not load',
        message: 'Pull down to retry your dashboard.',
      ),
    );
  }
}

class LiveStatusStrip extends ConsumerWidget {
  const LiveStatusStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorCount = ref.watch(liveLabVisitorCountProvider);
    final session = ref.watch(activeSessionProvider);
    final booking = ref.watch(activeBookingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Now at IDEA Lab',
          actionLabel: 'Open',
          onAction: () => context.go('/akathalam'),
        ),
        const SizedBox(height: RC5DesignTokens.space3),
        SizedBox(
          height: 116,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _LiveStatusCard(
                icon: Icons.groups_rounded,
                title: visitorCount.maybeWhen(
                  data: (count) => '$count active now',
                  orElse: () => 'Live count',
                ),
                subtitle: 'Realtime lab occupancy',
                color: RC5DesignTokens.primary,
              ),
              _LiveStatusCard(
                icon: session.valueOrNull == null
                    ? Icons.qr_code_scanner_rounded
                    : Icons.verified_rounded,
                title: session.valueOrNull == null
                    ? 'Ready to check in'
                    : 'You are checked in',
                subtitle: session.valueOrNull == null
                    ? 'Scan the QR at the lab'
                    : 'Remember to check out',
                color: session.valueOrNull == null
                    ? RC5DesignTokens.ink
                    : RC5DesignTokens.success,
              ),
              _LiveStatusCard(
                icon: Icons.construction_rounded,
                title: _bookingTitle(booking.valueOrNull),
                subtitle: _bookingSubtitle(booking.valueOrNull),
                color: RC5DesignTokens.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = [
      _QuickAction(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Check In',
        subtitle: 'Start lab session',
        route: '/lab/scan',
      ),
      _QuickAction(
        icon: Icons.construction_rounded,
        title: 'Book Tool',
        subtitle: 'Reserve machines',
        route: '/tools',
      ),
      _QuickAction(
        icon: Icons.folder_copy_rounded,
        title: 'Projects',
        subtitle: 'Continue builds',
        route: '/projects',
      ),
      _QuickAction(
        icon: Icons.event_rounded,
        title: 'Events',
        subtitle: 'Workshops & meetups',
        route: '/events',
      ),
      _QuickAction(
        icon: Icons.work_rounded,
        title: 'Opportunities',
        subtitle: 'Internships & roles',
        route: '/home',
      ),
      _QuickAction(
        icon: Icons.handshake_rounded,
        title: 'Mentorship',
        subtitle: 'Ask for support',
        route: '/home',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Quick actions'),
        const SizedBox(height: RC5DesignTokens.space3),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: RC5DesignTokens.space3,
            crossAxisSpacing: RC5DesignTokens.space3,
            childAspectRatio: 1.14,
          ),
          itemBuilder: (context, index) {
            final action = actions[index];
            return RC5Card(
              onTap: () => action.route == '/home'
                  ? _showComingSoon(context, action.title)
                  : context.push(action.route),
              backgroundColor: Colors.white,
              shadowOpacity: 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(action.icon, color: RC5DesignTokens.primary, size: 28),
                  const Spacer(),
                  Text(
                    action.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    action.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RC5DesignTokens.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class UpcomingEventsCarousel extends ConsumerWidget {
  const UpcomingEventsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(activeEventsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Upcoming events',
          actionLabel: 'View all',
          onAction: () => context.push('/events'),
        ),
        const SizedBox(height: RC5DesignTokens.space3),
        events.when(
          data: (items) {
            final upcoming = items.where((event) => !event.isPast).take(8);
            if (upcoming.isEmpty) {
              return const RC5EmptyState(
                icon: Icons.event_available_rounded,
                title: 'No events yet',
                message: 'Upcoming workshops and meetups will appear here.',
              );
            }
            return SizedBox(
              height: 238,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: upcoming.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: RC5DesignTokens.space3),
                itemBuilder: (context, index) {
                  final event = upcoming.elementAt(index);
                  return _EventPosterCard(event: event);
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 238,
            child: Row(
              children: [
                RC5Skeleton(width: 168, height: 238),
                SizedBox(width: RC5DesignTokens.space3),
                RC5Skeleton(width: 168, height: 238),
              ],
            ),
          ),
          error: (_, __) => const RC5EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Events could not load',
            message: 'Pull down to refresh your dashboard.',
          ),
        ),
      ],
    );
  }
}

class OpportunitiesPreview extends StatelessWidget {
  const OpportunitiesPreview({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _PreviewItem(
        title: 'Embedded systems intern',
        subtitle: 'MakerGram • Internship • Remote',
        icon: Icons.memory_rounded,
      ),
      _PreviewItem(
        title: 'Design volunteer crew',
        subtitle: 'IDEA Lab • Volunteering • Onsite',
        icon: Icons.palette_rounded,
      ),
    ];

    return _PreviewSection(
      title: 'Opportunities',
      actionLabel: 'Soon',
      items: items,
      emptyIcon: Icons.work_outline_rounded,
      onTap: (item) => _showComingSoon(context, 'Opportunities'),
    );
  }
}

class MentorshipSupportPreview extends StatelessWidget {
  const MentorshipSupportPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      gradient: RC5DesignTokens.softGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_rounded, color: RC5DesignTokens.ink),
              const SizedBox(width: RC5DesignTokens.space2),
              Expanded(
                child: Text(
                  'Mentorship & Support',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          Text(
            'Request help with team members, technical blockers, materials, or project guidance.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: RC5DesignTokens.textSecondary,
                ),
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          RC5Button(
            label: 'Request support',
            icon: Icons.arrow_forward_rounded,
            onPressed: () => _showComingSoon(context, 'Mentorship & Support'),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class ActiveProjectsPreview extends ConsumerWidget {
  const ActiveProjectsPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(userProjectsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Active projects',
          actionLabel: 'View all',
          onAction: () => context.push('/projects'),
        ),
        const SizedBox(height: RC5DesignTokens.space3),
        projects.when(
          data: (items) {
            final activeProjects = items.take(3).toList();
            if (activeProjects.isEmpty) {
              return RC5EmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No active projects',
                message: 'Create or join a project to start building.',
                primaryActionLabel: 'Browse projects',
                onPrimaryAction: () => context.push('/projects'),
              );
            }
            return Column(
              children: activeProjects.map((project) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: RC5DesignTokens.space3),
                  child: _ProjectPreviewCard(project: project),
                );
              }).toList(),
            );
          },
          loading: () => const RC5SkeletonList(itemCount: 3),
          error: (_, __) => const RC5EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Projects could not load',
            message: 'Pull down to refresh and try again.',
          ),
        ),
      ],
    );
  }
}

class KnowledgePreview extends StatelessWidget {
  const KnowledgePreview({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _PreviewItem(
        title: 'Laser cutter safety basics',
        subtitle: 'Machine guide • 5 min read',
        icon: Icons.local_fire_department_rounded,
      ),
      _PreviewItem(
        title: 'How to prepare files for CNC',
        subtitle: 'Fabrication guide • Draft',
        icon: Icons.architecture_rounded,
      ),
      _PreviewItem(
        title: 'Arduino project checklist',
        subtitle: 'Electronics • Community article',
        icon: Icons.developer_board_rounded,
      ),
    ];

    return _PreviewSection(
      title: 'Knowledge base',
      actionLabel: 'Soon',
      items: items,
      emptyIcon: Icons.menu_book_rounded,
      onTap: (item) => _showComingSoon(context, 'Knowledge Base'),
    );
  }
}

class _LiveStatusCard extends StatelessWidget {
  const _LiveStatusCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: RC5DesignTokens.space3),
      child: RC5Card(
        backgroundColor: Colors.white,
        shadowOpacity: 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: RC5DesignTokens.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventPosterCard extends StatelessWidget {
  const _EventPosterCard({required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: RC5Card(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/events/${event.id}'),
        shadowOpacity: 0.85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd - 1),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                Image.network(
                  event.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PosterFallback(),
                )
              else
                const _PosterFallback(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      RC5DesignTokens.ink.withValues(alpha: 0.76),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RC5Chip(
                      label: _formatDate(event.eventDate),
                      compact: true,
                      isSelected: true,
                      color: RC5DesignTokens.primary,
                    ),
                    const SizedBox(height: RC5DesignTokens.space2),
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.venue ?? 'IDEA Lab',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectPreviewCard extends StatelessWidget {
  const _ProjectPreviewCard({required this.project});

  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      backgroundColor: Colors.white,
      shadowOpacity: 0.65,
      onTap: () => context.push('/projects/${project.id}'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: RC5DesignTokens.primaryGradient,
              borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
            ),
            child: const Icon(Icons.rocket_launch_rounded, color: Colors.white),
          ),
          const SizedBox(width: RC5DesignTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.status} • ${project.visibility}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: RC5DesignTokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.actionLabel,
    required this.items,
    required this.emptyIcon,
    required this.onTap,
  });

  final String title;
  final String actionLabel;
  final List<_PreviewItem> items;
  final IconData emptyIcon;
  final ValueChanged<_PreviewItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, actionLabel: actionLabel),
        const SizedBox(height: RC5DesignTokens.space3),
        if (items.isEmpty)
          RC5EmptyState(
            icon: emptyIcon,
            title: 'Nothing here yet',
            message: 'New items will appear as the community grows.',
          )
        else
          Column(
            children: items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: RC5DesignTokens.space3),
                child: RC5Card(
                  backgroundColor: Colors.white,
                  shadowOpacity: 0.6,
                  onTap: () => onTap(item),
                  child: Row(
                    children: [
                      Icon(item.icon, color: RC5DesignTokens.primary, size: 26),
                      const SizedBox(width: RC5DesignTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: RC5DesignTokens.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: RC5DesignTokens.ink,
                ),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: RC5DesignTokens.surface,
            foregroundColor: RC5DesignTokens.ink,
          ),
          icon: Icon(icon),
        ),
        if (count > 0)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: RC5DesignTokens.error,
                borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PosterFallback extends StatelessWidget {
  const _PosterFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: RC5DesignTokens.primaryGradient),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
}

class _PreviewItem {
  const _PreviewItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

String _firstName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'Maker';
  return trimmed.split(RegExp(r'\s+')).first;
}

String _profileHandle(UserModel user) {
  final localPart = user.email.split('@').first;
  final normalized = localPart
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  return '@${normalized.isEmpty ? user.id.substring(0, 6) : normalized}';
}

String _bookingTitle(BookingModel? booking) {
  if (booking == null) return 'No active booking';
  return booking.toolName ?? 'Tool booking';
}

String _bookingSubtitle(BookingModel? booking) {
  if (booking == null) return 'Book tools when you need them';
  return '${booking.status} until ${_timeOnly(booking.slotEnd)}';
}

String _formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final local = value.toLocal();
  return '${months[local.month - 1]} ${local.day}';
}

String _timeOnly(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}

void _showComingSoon(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$feature is coming in the next RC5 slice.'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
