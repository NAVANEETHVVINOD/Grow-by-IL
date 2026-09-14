import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_detail_controller.dart';
import '../../models/work_request_detail.dart';
import '../../models/work_request_summary.dart';
import '../widgets/work_request_cancellation_card.dart';
import '../widgets/work_request_collaborators_section.dart';
import '../widgets/work_request_detail_header.dart';
import '../widgets/work_request_detail_summary.dart';
import '../widgets/work_request_links_section.dart';
import '../widgets/work_request_rejection_card.dart';
import '../widgets/work_request_status_timeline.dart';
import 'work_requests_screen.dart' show RC5SectionHeader;

class WorkRequestDetailScreen extends ConsumerWidget {
  const WorkRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(workRequestDetailProvider(requestId));

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const RC5Loading(label: 'Loading request'),
          error: (error, stackTrace) =>
              _ErrorState(onBack: () => context.pop()),
          data: (detail) {
            if (detail == null) {
              return _NotFoundState(onBack: () => context.pop());
            }
            return _DetailBody(detail: detail);
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final WorkRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: WorkRequestDetailHeader(
              detail: detail,
              onBack: () => context.pop(),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: WorkRequestDetailSummary(detail: detail),
          ),
        ),
        if (detail.leaderName != null ||
            detail.collaboratorNames.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _Section(
                icon: Icons.groups_2_rounded,
                title: 'Collaborators',
                subtitle: 'Leader owns approvals; members can view progress.',
                child: WorkRequestCollaboratorsSection(
                  leaderName: detail.leaderName,
                  collaboratorNames: detail.collaboratorNames,
                ),
              ),
            ),
          ),
        ],
        if (detail.externalLinks.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _Section(
                icon: Icons.link_rounded,
                title: 'Design links',
                subtitle: 'External files stay on their original platform.',
                child: WorkRequestLinksSection(links: detail.externalLinks),
              ),
            ),
          ),
        ],
        if (detail.statusHistory.isNotEmpty) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _Section(
                icon: Icons.timeline_rounded,
                title: 'Status timeline',
                subtitle: 'Public updates for this request.',
                child: WorkRequestStatusTimeline(events: detail.statusHistory),
              ),
            ),
          ),
        ],
        if (detail.status == WorkRequestStatus.rejected) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: WorkRequestRejectionCard(
                detail: detail,
                onResubmit: () => context.push('/work-requests/create'),
              ),
            ),
          ),
        ],
        if (detail.status == WorkRequestStatus.cancelled) ...[
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: WorkRequestCancellationCard(detail: detail),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RC5SectionHeader(title: title, subtitle: subtitle, icon: icon),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: RC5EmptyState(
          icon: Icons.search_off_rounded,
          title: 'Request not found',
          message: 'This request may have been removed or the link is invalid.',
          primaryActionLabel: 'Go back',
          onPrimaryAction: onBack,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: RC5EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load request',
          message: 'Something went wrong while loading this request.',
          primaryActionLabel: 'Go back',
          onPrimaryAction: onBack,
        ),
      ),
    );
  }
}
