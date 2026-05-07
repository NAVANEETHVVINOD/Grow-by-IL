import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/models/event_model.dart';
import '../../../../shared/models/project_model.dart';
import '../../../../shared/widgets/neo_card.dart';
import '../../../../shared/widgets/shimmer_skeleton.dart';
import '../../projects/domain/project_providers.dart';
import '../domain/event_providers.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                'Explore',
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
              labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16),
              tabs: const [
                Tab(text: 'Events'),
                Tab(text: 'Projects'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _EventsTab(),
                  const _ProjectsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(activeEventsProvider);

    return eventsAsync.when(
      data: (events) => events.isEmpty
          ? const Center(child: Text('No active events found.'))
          : RefreshIndicator(
              onRefresh: () => ref.refresh(activeEventsProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.lg),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventCard(event: event);
                },
              ),
            ),
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(AppSizes.lg),
        itemCount: 3,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSizes.md),
          child: ShimmerSkeleton(width: double.infinity, height: 180),
        ),
      ),
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
              // Event Image Placeholder
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.navy.withOpacity(0.8), AppColors.navy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: event.imageUrl != null
                    ? Image.network(event.imageUrl!, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          _getIconForType(event.type),
                          size: 48,
                          color: AppColors.yellow,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.type.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${event.rsvpCount}${event.capacity != null ? '/${event.capacity}' : ''} attending',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
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
                    if (event.organizationName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'by ${event.organizationName}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'workshop': return Icons.engineering_rounded;
      case 'hackathon': return Icons.code_rounded;
      case 'talk': return Icons.record_voice_over_rounded;
      case 'competition': return Icons.emoji_events_rounded;
      default: return Icons.event_rounded;
    }
  }
}

class _ProjectsTab extends ConsumerWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(publicProjectsProvider);

    return projectsAsync.when(
      data: (projects) => projects.isEmpty
          ? const Center(child: Text('No public projects found.'))
          : RefreshIndicator(
              onRefresh: () => ref.refresh(publicProjectsProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.lg),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return _ProjectCard(project: project);
                },
              ),
            ),
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final ProjectModel project;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.md),
      child: GestureDetector(
        onTap: () => context.push('/projects/${project.id}'),
        child: NeoCard(
          color: Colors.white,
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.navy, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: project.coverImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(project.coverImageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.architecture_rounded, color: AppColors.navy),
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeChip(type: project.type),
                        const Spacer(),
                        if (!project.isActive)
                          Text(
                            project.status.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      project.description ?? 'No description',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
