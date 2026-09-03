import 'package:flutter/material.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../models/work_request_detail.dart';
import '../../models/work_request_summary.dart';

/// Only rendered when `detail.status == WorkRequestStatus.cancelled`.
class WorkRequestCancellationCard extends StatelessWidget {
  const WorkRequestCancellationCard({super.key, required this.detail});

  final WorkRequestDetail detail;

  bool get _wasActiveBeforeCancellation => detail.statusHistory.any(
        (e) =>
            e.status == WorkRequestStatus.approved ||
            e.status == WorkRequestStatus.inProgress,
      );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Request cancelled',
      child: RC5Card(
        backgroundColor: const Color(0xFFF3F4F6),
        padding: const EdgeInsets.all(16),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.block_rounded,
                  color: RC5DesignTokens.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cancelled',
                  style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
                ),
              ],
            ),
            if (detail.cancellationReason != null &&
                detail.cancellationReason!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                detail.cancellationReason!,
                style: RC5DesignTokens.body.copyWith(fontSize: 13),
              ),
            ],
            if (_wasActiveBeforeCancellation) ...[
              const SizedBox(height: 10),
              Text(
                'Any in-progress fabrication work for this request has been '
                'stopped.',
                style: RC5DesignTokens.body.copyWith(
                  fontSize: 12,
                  color: RC5DesignTokens.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
