import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../models/work_request_status_event.dart';
import '../../models/work_request_summary.dart';

/// Renders the public status history in chronological order (oldest first),
/// regardless of the order events were supplied in, so the caller never has
/// to remember to pre-sort seed/mock data.
class WorkRequestStatusTimeline extends StatelessWidget {
  const WorkRequestStatusTimeline({super.key, required this.events});

  final List<WorkRequestStatusEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) return const SizedBox.shrink();

    final sorted = List<WorkRequestStatusEvent>.from(events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Semantics(
      container: true,
      label: 'Status timeline, ${sorted.length} updates',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < sorted.length; i++)
            _TimelineRow(
              event: sorted[i],
              isLast: i == sorted.length - 1,
              isCurrent: i == sorted.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.event,
    required this.isLast,
    required this.isCurrent,
  });

  final WorkRequestStatusEvent event;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final dotColor =
        isCurrent ? RC5DesignTokens.ink : RC5DesignTokens.textSecondary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? dotColor : Colors.white,
                  border: Border.all(color: dotColor, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: RC5DesignTokens.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.status.label,
                    style: RC5DesignTokens.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.yMMMd().add_jm().format(event.timestamp),
                    style: RC5DesignTokens.body.copyWith(
                      color: RC5DesignTokens.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  if (event.note != null && event.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: RC5DesignTokens.neutralSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: RC5DesignTokens.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        event.note!,
                        style: RC5DesignTokens.body.copyWith(
                          fontSize: 12,
                          color: RC5DesignTokens.ink,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
