import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../constants/work_request_options.dart';
import '../../models/work_request_summary.dart';

class WorkRequestCard extends StatelessWidget {
  const WorkRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.onActionSelected,
  });

  final WorkRequestSummary request;
  final VoidCallback onTap;
  final ValueChanged<String>? onActionSelected;

  @override
  Widget build(BuildContext context) {
    final hasLeader = request.leaderName != null;
    final formattedEstDate = request.estimatedCompletionDate != null
        ? DateFormat.yMMMd().format(request.estimatedCompletionDate!)
        : null;

    return Semantics(
      container: true,
      label:
          'Work Request: ${request.title}. Status: ${request.status.label}. Priority: ${request.priority.label}',
      child: RC5Card(
        onTap: onTap,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Category Icon & Badges
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: RC5DesignTokens.neutralSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: RC5DesignTokens.border,
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: RC5DesignTokens.ink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      WorkRequestStatusBadge(status: request.status),
                      WorkRequestPriorityBadge(priority: request.priority),
                    ],
                  ),
                ),
                // Trailing popup menu button
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: RC5DesignTokens.textSecondary,
                    size: 20,
                  ),
                  onSelected: onActionSelected,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'open',
                      child: Text('Open details'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate request'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Middle Section: Title & Purpose
            Text(
              request.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 3),
            Text(
              request.purpose,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: RC5DesignTokens.body.copyWith(
                color: RC5DesignTokens.textSecondary,
                fontSize: 13,
              ),
            ),

            // Subcategories labels list
            if (request.subcategoryLabels.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final label in request.subcategoryLabels)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: RC5DesignTokens.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: RC5DesignTokens.body.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: RC5DesignTokens.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],

            const Divider(
                height: 24, color: RC5DesignTokens.border, thickness: 1),

            // Footer Section: Updated time, Est completion, Leader avatar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Updated ${_formatTimeAgo(request.updatedAt)}',
                        style: RC5DesignTokens.body.copyWith(
                          color: RC5DesignTokens.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (formattedEstDate != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Est. Completion: $formattedEstDate',
                          style: RC5DesignTokens.body.copyWith(
                            color: RC5DesignTokens.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (hasLeader) ...[
                  Tooltip(
                    message: 'Reviewer: ${request.leaderName}',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: RC5DesignTokens.border,
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                NetworkImage(request.leaderAvatarUrl!),
                            onBackgroundImageError: (_, __) {},
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          request.leaderName!,
                          style: RC5DesignTokens.body.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      final m = difference.inMinutes;
      return m <= 0 ? 'just now' : '$m min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class WorkRequestStatusBadge extends StatelessWidget {
  const WorkRequestStatusBadge({super.key, required this.status});
  final WorkRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      WorkRequestStatus.draft => (const Color(0xFFFFF7A1), RC5DesignTokens.ink),
      WorkRequestStatus.submitted || WorkRequestStatus.reviewed => (
          const Color(0xFFDFF4FF),
          RC5DesignTokens.ink
        ),
      WorkRequestStatus.approved => (
          const Color(0xFFF5D6F7),
          RC5DesignTokens.ink
        ),
      WorkRequestStatus.inProgress => (
          const Color(0xFFE0E7FF),
          RC5DesignTokens.ink
        ),
      WorkRequestStatus.readyForPickup => (
          const Color(0xFFFFE0B2),
          RC5DesignTokens.ink
        ),
      WorkRequestStatus.completed => (
          const Color(0xFFDDF5D7),
          RC5DesignTokens.ink
        ),
      WorkRequestStatus.changesRequested => (
          const Color(0xFFFFD6D6),
          RC5DesignTokens.ink
        ),
      _ => (const Color(0xFFF3F4F6), RC5DesignTokens.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RC5DesignTokens.border,
          width: 1.5,
        ),
      ),
      child: Text(
        status.label,
        style: RC5DesignTokens.body.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }
}

class WorkRequestPriorityBadge extends StatelessWidget {
  const WorkRequestPriorityBadge({super.key, required this.priority});
  final WorkRequestPriority priority;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (priority) {
      WorkRequestPriority.low => (
          const Color(0xFFF3F4F6),
          RC5DesignTokens.textSecondary
        ),
      WorkRequestPriority.normal => (
          const Color(0xFFDFF4FF),
          RC5DesignTokens.ink
        ),
      WorkRequestPriority.high => (
          const Color(0xFFFFD6D6),
          RC5DesignTokens.ink
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: RC5DesignTokens.border,
          width: 1.5,
        ),
      ),
      child: Text(
        priority.label,
        style: RC5DesignTokens.body.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }
}
