import 'package:flutter/material.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../models/work_request_detail.dart';

/// Only rendered when `detail.status == WorkRequestStatus.rejected`.
class WorkRequestRejectionCard extends StatelessWidget {
  const WorkRequestRejectionCard({
    super.key,
    required this.detail,
    required this.onResubmit,
  });

  final WorkRequestDetail detail;
  final VoidCallback onResubmit;

  @override
  Widget build(BuildContext context) {
    final isPermanent = detail.isPermanentlyRejected;

    return Semantics(
      container: true,
      label: isPermanent
          ? 'Request rejected permanently'
          : 'Request rejected, resubmission available',
      child: RC5Card(
        backgroundColor: const Color(0xFFFFEAEA),
        padding: const EdgeInsets.all(16),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cancel_outlined,
                  color: RC5DesignTokens.ink,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Rejected',
                  style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
                ),
              ],
            ),
            if (detail.rejectionReason != null &&
                detail.rejectionReason!.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Reason',
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: RC5DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail.rejectionReason!,
                style: RC5DesignTokens.body.copyWith(fontSize: 13),
              ),
            ],
            const SizedBox(height: 14),
            if (isPermanent)
              Text(
                'This request cannot be resubmitted. Please contact the core team.',
                style: RC5DesignTokens.body.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: RC5DesignTokens.ink,
                ),
              )
            else
              RC5Button(
                label: 'Create New Request',
                icon: Icons.add_rounded,
                onPressed: onResubmit,
              ),
          ],
        ),
      ),
    );
  }
}
