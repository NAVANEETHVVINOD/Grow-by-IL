import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:grow/features/explore/domain/event_providers.dart';
import 'package:grow/features/lab/domain/lab_providers.dart';
import 'package:grow/features/lab/domain/tool_providers.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/widgets/rc5/rc5_widgets.dart';

class AkathalamScreen extends ConsumerWidget {
  const AkathalamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorCount = ref.watch(liveLabVisitorCountProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final events = ref.watch(activeEventsProvider);
    final tools = ref.watch(toolsProvider);

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Text(
              'അകത്തളം',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: RC5DesignTokens.ink,
                  ),
            ),
            const SizedBox(height: RC5DesignTokens.space2),
            Text(
              'The living IDEA Lab space for check-ins, events, tools, and what is happening now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: RC5DesignTokens.textSecondary,
                  ),
            ),
            const SizedBox(height: RC5DesignTokens.space5),
            _StatusRail(
              visitorCount: visitorCount,
              toolCount: tools.maybeWhen(
                data: (items) => items.length,
                orElse: () => null,
              ),
              eventCount: events.maybeWhen(
                data: (items) => items.where((event) => !event.isPast).length,
                orElse: () => null,
              ),
            ),
            const SizedBox(height: RC5DesignTokens.space5),
            _CheckInCard(isCheckedIn: activeSession.valueOrNull != null),
            const SizedBox(height: RC5DesignTokens.space5),
            const _ActionGrid(),
            const SizedBox(height: RC5DesignTokens.space5),
            _UpcomingEvents(events: events),
          ],
        ),
      ),
    );
  }
}

class _StatusRail extends StatelessWidget {
  const _StatusRail({
    required this.visitorCount,
    required this.toolCount,
    required this.eventCount,
  });

  final AsyncValue<int> visitorCount;
  final int? toolCount;
  final int? eventCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: RC5DesignTokens.space2,
      runSpacing: RC5DesignTokens.space2,
      children: [
        const _StatusChip(
          icon: Icons.bolt_rounded,
          label: 'Electricity',
          value: 'No info',
          color: RC5DesignTokens.warning,
        ),
        const _StatusChip(
          icon: Icons.wifi_rounded,
          label: 'Wi-Fi',
          value: 'No info',
          color: RC5DesignTokens.primary,
        ),
        _StatusChip(
          icon: Icons.groups_rounded,
          label: 'Active',
          value: visitorCount.maybeWhen(
            data: (count) => '$count now',
            orElse: () => '...',
          ),
          color: RC5DesignTokens.success,
        ),
        _StatusChip(
          icon: Icons.construction_rounded,
          label: 'Tools',
          value: toolCount == null ? '...' : '$toolCount listed',
          color: RC5DesignTokens.accent,
        ),
        _StatusChip(
          icon: Icons.event_rounded,
          label: 'Events',
          value: eventCount == null ? '...' : '$eventCount upcoming',
          color: RC5DesignTokens.ink,
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
        border: Border.all(color: RC5DesignTokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RC5DesignTokens.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: RC5DesignTokens.ink,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.isCheckedIn});

  final bool isCheckedIn;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      gradient: isCheckedIn
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFECFDF5), Color(0xFFF8F7FF)],
            )
          : RC5DesignTokens.softGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCheckedIn
                      ? RC5DesignTokens.success
                      : RC5DesignTokens.ink,
                  borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
                ),
                child: Icon(
                  isCheckedIn ? Icons.verified_rounded : Icons.qr_code_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: RC5DesignTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCheckedIn ? 'You are inside IDEA Lab' : 'Lab Check-in',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isCheckedIn
                          ? 'Keep building. Check out when you leave.'
                          : 'Scan the lab QR to start your session.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: RC5DesignTokens.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: RC5DesignTokens.space4),
          RC5Button(
            label: isCheckedIn ? 'Open Check-out' : 'Scan to Check In',
            icon: isCheckedIn ? Icons.logout_rounded : Icons.qr_code_scanner,
            fullWidth: true,
            onPressed: () => context.push('/lab/scan'),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid();

  @override
  Widget build(BuildContext context) {
    const actions = [
      _AkathalamAction(
        icon: Icons.science_rounded,
        title: 'Lab',
        subtitle: 'Sessions and occupancy',
        route: '/lab',
      ),
      _AkathalamAction(
        icon: Icons.construction_rounded,
        title: 'Book Tool',
        subtitle: 'Machines and facilities',
        route: '/tools',
      ),
      _AkathalamAction(
        icon: Icons.event_rounded,
        title: 'Events',
        subtitle: 'Upcoming and past',
        route: '/events',
      ),
      _AkathalamAction(
        icon: Icons.explore_rounded,
        title: 'Explore',
        subtitle: 'IDEA Lab resources',
        route: '/explore',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: RC5DesignTokens.space3,
        crossAxisSpacing: RC5DesignTokens.space3,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return RC5Card(
          onTap: () => context.push(action.route),
          backgroundColor: Colors.white,
          shadowOpacity: 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(action.icon, color: RC5DesignTokens.primary, size: 28),
              const Spacer(),
              Text(
                action.title,
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
    );
  }
}

class _UpcomingEvents extends StatelessWidget {
  const _UpcomingEvents({required this.events});

  final AsyncValue<List<EventModel>> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Upcoming events',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => context.push('/events'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: RC5DesignTokens.space3),
        events.when(
          data: (items) {
            final eventList =
                items.where((event) => !event.isPast).take(3).toList();
            if (eventList.isEmpty) {
              return const RC5EmptyState(
                icon: Icons.event_available_rounded,
                title: 'No events queued',
                message: 'New workshops and meetups will appear here.',
              );
            }

            return Column(
              children: eventList.map((event) {
                return Padding(
                  padding:
                      const EdgeInsets.only(bottom: RC5DesignTokens.space3),
                  child: RC5Card(
                    onTap: () => context.push('/events/${event.id}'),
                    backgroundColor: Colors.white,
                    shadowOpacity: 0.65,
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: RC5DesignTokens.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              RC5DesignTokens.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: RC5DesignTokens.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                event.venue ?? 'IDEA Lab',
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
            );
          },
          loading: () => const RC5SkeletonList(itemCount: 3, itemHeight: 78),
          error: (_, __) => const RC5EmptyState(
            icon: Icons.wifi_off_rounded,
            title: 'Events could not load',
            message: 'Check your connection and try again.',
          ),
        ),
      ],
    );
  }
}

class _AkathalamAction {
  const _AkathalamAction({
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
