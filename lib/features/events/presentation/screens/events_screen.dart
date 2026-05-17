import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:grow/core/constants/app_colors.dart';
import 'package:grow/core/constants/app_sizes.dart';
import 'package:grow/shared/models/event_model.dart';
import 'package:grow/shared/widgets/neo_card.dart';
import 'package:grow/shared/widgets/shimmer_skeleton.dart';
import 'package:grow/features/explore/domain/event_providers.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Text(
                'Events',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.navy,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.yellow,
              indicatorWeight: 4,
              labelStyle: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'UPCOMING'),
                Tab(text: 'MY RSVPS'),
                Tab(text: 'PAST'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const _EventsListTab(statusFilter: 'upcoming'),
                  const _MyRsvpsTab(),
                  const _EventsListTab(statusFilter: 'completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsListTab extends ConsumerWidget {
  const _EventsListTab({required this.statusFilter});
  final String statusFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(activeEventsProvider);

    return eventsAsync.when(
      data: (events) {
        final filteredEvents = statusFilter == 'upcoming'
            ? events
                .where((e) => e.status == 'upcoming' || e.status == 'ongoing')
                .toList()
            : events.where((e) => e.status == 'completed').toList();

        if (filteredEvents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  statusFilter == 'upcoming'
                      ? Icons.event_busy_rounded
                      : Icons.history_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  statusFilter == 'upcoming'
                      ? 'No upcoming events'
                      : 'No past events',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(activeEventsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.lg),
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              return _EventCard(event: event);
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: 3,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.md),
          child: ShimmerSkeleton(width: double.infinity, height: 120),
        ),
      ),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _MyRsvpsTab extends ConsumerWidget {
  const _MyRsvpsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rsvpsAsync = ref.watch(myRsvpsProvider);

    return rsvpsAsync.when(
      data: (rsvps) {
        if (rsvps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bookmark_border_rounded,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'You haven\'t RSVP\'d to any events',
                  style: GoogleFonts.dmSans(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(myRsvpsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSizes.lg),
            itemCount: rsvps.length,
            itemBuilder: (context, index) {
              final rsvp = rsvps[index];
              return FutureBuilder(
                future: ref
                    .read(eventRepositoryProvider)
                    .getEventById(rsvp.eventId),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _EventCard(event: snapshot.data!);
                  }
                  return const SizedBox.shrink();
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});
  final EventModel event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: GestureDetector(
        onTap: () => context.push('/events/${event.id}'),
        child: NeoCard(
          color: Colors.white,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusMd),
                  ),
                  child: Image.network(
                    event.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeChip(type: event.type),
                        const Spacer(),
                        Text(
                          '${event.rsvpCount} attending',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.eventDate.toLocal().toString().substring(5, 16),
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.yellow,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    );
  }
}
