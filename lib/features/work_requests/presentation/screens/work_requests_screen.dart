import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../application/providers/work_request_dashboard_controller.dart';
import '../../constants/work_request_options.dart';
import '../../models/work_request_summary.dart';
import '../widgets/work_request_card.dart';

class WorkRequestsScreen extends ConsumerWidget {
  const WorkRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: _WorkRequestHeader(
                  onBack: () => context.pop(),
                  onCreate: () => context.push('/work-requests/create'),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Metrics Section (Responsive grid)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _MetricsSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Active Draft Section
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _DraftSection()),
            ),

            // Filters Section
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _FiltersSection()),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Requests List Section
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: _RequestListSection(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: RC5Button(
          label: 'Start a Work Request',
          icon: Icons.add_rounded,
          fullWidth: true,
          onPressed: () => context.push('/work-requests/create'),
        ),
      ),
    );
  }
}

class _WorkRequestHeader extends StatelessWidget {
  const _WorkRequestHeader({
    required this.onBack,
    required this.onCreate,
  });

  final VoidCallback onBack;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _IconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Work Requests',
          style: RC5DesignTokens.hero.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 8),
        Text(
          'Turn ideas, fabrication needs, and technical help into trackable lab work across IDEA Lab and Fab Lab.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: RC5Button(
                label: 'New request',
                icon: Icons.auto_awesome_rounded,
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricsSection extends ConsumerWidget {
  const _MetricsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestDashboardControllerProvider);
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;

    final items = [
      _MetricItem(
        label: 'Drafts',
        value: '${state.draftCount}',
        icon: Icons.edit_note_rounded,
        color: const Color(0xFFFFF7A1),
      ),
      _MetricItem(
        label: 'Submitted',
        value: '${state.submittedCount}',
        icon: Icons.manage_search_rounded,
        color: const Color(0xFFDFF4FF),
      ),
      _MetricItem(
        label: 'Approved',
        value: '${state.approvedCount}',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFFF5D6F7),
      ),
      _MetricItem(
        label: 'Completed',
        value: '${state.completedCount}',
        icon: Icons.assignment_turned_in_outlined,
        color: const Color(0xFFDDF5D7),
      ),
    ];

    if (isTablet) {
      return Row(
        children: items
            .map(
              (item) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: item == items.last ? 0 : 10,
                  ),
                  child: _MetricCard(item: item),
                ),
              ),
            )
            .toList(),
      );
    } else {
      // 2x2 grid for mobile
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _MetricCard(item: items[0])),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(item: items[1])),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MetricCard(item: items[2])),
              const SizedBox(width: 10),
              Expanded(child: _MetricCard(item: items[3])),
            ],
          ),
        ],
      );
    }
  }
}

class _MetricItem {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.item});
  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      padding: const EdgeInsets.all(14),
      backgroundColor: item.color,
      radius: 18,
      shadowOpacity: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: RC5DesignTokens.ink, size: 20),
          const SizedBox(height: 12),
          Text(
            item.value,
            style: RC5DesignTokens.cardTitle
                .copyWith(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftSection extends ConsumerWidget {
  const _DraftSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((state) => state.draft),
    );

    if (!draft.hasAnyInput) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: RC5Card(
        backgroundColor: const Color(0xFFFFF7A1),
        padding: const EdgeInsets.all(16),
        radius: 18,
        child: Row(
          children: [
            const Icon(
              Icons.edit_note_rounded,
              color: RC5DesignTokens.ink,
              size: 28,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.title.isEmpty ? 'Untitled Work Request' : draft.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RC5DesignTokens.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Draft - Continue editing to submit your request.',
                    style: RC5DesignTokens.body.copyWith(
                      color: RC5DesignTokens.ink.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            RC5Button(
              label: 'Continue',
              height: 40,
              onPressed: () => context.push('/work-requests/create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSection extends ConsumerWidget {
  const _FiltersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestDashboardControllerProvider);
    final controller =
        ref.read(workRequestDashboardControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const RC5SectionHeader(
          title: 'Requests List',
          subtitle: 'Search, filter, and track requests lifecycle.',
          icon: Icons.list_alt_rounded,
        ),
        const SizedBox(height: 16),
        RC5SearchBar(
          hintText: 'Search requests (title, purpose, process...)',
          initialValue: state.searchQuery,
          onChanged: (val) => controller.setSearchQuery(val),
        ),
        const SizedBox(height: 12),
        // Status filters group
        Text(
          'Status',
          style: RC5DesignTokens.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: RC5DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        RC5FilterChipGroup<WorkRequestStatus?>(
          options: const [
            null,
            WorkRequestStatus.draft,
            WorkRequestStatus.submitted,
            WorkRequestStatus.approved,
            WorkRequestStatus.completed,
            WorkRequestStatus.needsChanges,
          ],
          selectedOption: state.statusFilter,
          labelMapper: (status) => status == null ? 'All' : status.label,
          onSelected: (status) => controller.setStatusFilter(status),
        ),
        const SizedBox(height: 12),
        // Priority & Sort layout row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priority',
                    style: RC5DesignTokens.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: RC5DesignTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RC5FilterChipGroup<WorkRequestPriority?>(
                    options: const [
                      null,
                      WorkRequestPriority.low,
                      WorkRequestPriority.normal,
                      WorkRequestPriority.high,
                    ],
                    selectedOption: state.priorityFilter,
                    labelMapper: (prio) => prio == null ? 'All' : prio.label,
                    onSelected: (prio) => controller.setPriorityFilter(prio),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort by',
                  style: RC5DesignTokens.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: RC5DesignTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: RC5DesignTokens.border,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<WorkRequestSortBy>(
                      value: state.sortBy,
                      icon: const Icon(Icons.arrow_drop_down_rounded,
                          color: RC5DesignTokens.ink),
                      style: RC5DesignTokens.body.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          controller.setSortBy(val);
                        }
                      },
                      items: [
                        for (final sort in WorkRequestSortBy.values)
                          DropdownMenuItem(
                            value: sort,
                            child: Text(sort.label),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _RequestListSection extends ConsumerWidget {
  const _RequestListSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestDashboardControllerProvider);

    if (state.isLoading) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: RC5Loading(label: 'Loading requests'),
        ),
      );
    }

    if (state.requests.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: RC5EmptyState(
            icon: Icons.assignment_late_outlined,
            title: 'No requests found',
            message:
                'No requests match your current filters and search query. Try clearing your filters.',
            primaryActionLabel: 'Clear filters',
            onPrimaryAction: () {
              final controller =
                  ref.read(workRequestDashboardControllerProvider.notifier);
              controller.setSearchQuery('');
              controller.setStatusFilter(null);
              controller.setPriorityFilter(null);
            },
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        children: [
          for (var index = 0; index < state.requests.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == state.requests.length - 1 ? 0 : 12,
              ),
              child: WorkRequestCard(
                request: state.requests[index],
                onTap: () {
                  final request = state.requests[index];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Request details for "${request.title}" coming in the next update.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onActionSelected: (action) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Action "$action" coming in the next update.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class RC5SectionHeader extends StatelessWidget {
  const RC5SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: RC5DesignTokens.primary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: RC5DesignTokens.ink,
              width: RC5DesignTokens.borderWidth,
            ),
          ),
          child: Icon(icon, color: RC5DesignTokens.ink, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: RC5DesignTokens.sectionTitle),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: RC5DesignTokens.body.copyWith(
                  color: RC5DesignTokens.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      onTap: onTap,
      padding: EdgeInsets.zero,
      radius: 16,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: RC5DesignTokens.ink, size: 22),
      ),
    );
  }
}
