import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../models/work_request_detail.dart';
import 'work_request_card.dart'
    show WorkRequestStatusBadge, WorkRequestPriorityBadge;

/// The bulk of a Work Request's descriptive content: status/priority,
/// purpose, description, quantity, fabrication types, completion date,
/// design/material info, and the student-safe placeholders for queue,
/// machine assignment, and payment state.
class WorkRequestDetailSummary extends StatelessWidget {
  const WorkRequestDetailSummary({super.key, required this.detail});

  final WorkRequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final formattedCompletion = detail.preferredCompletionDate != null
        ? DateFormat.yMMMd().format(detail.preferredCompletionDate!)
        : null;

    return RC5Card(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(18),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              WorkRequestStatusBadge(status: detail.status),
              WorkRequestPriorityBadge(priority: detail.priority),
            ],
          ),
          const SizedBox(height: 16),
          _Label('Purpose'),
          Text(detail.purpose,
              style: RC5DesignTokens.body.copyWith(fontSize: 14)),
          const SizedBox(height: 14),
          _Label('Description'),
          Text(
            detail.description,
            style: RC5DesignTokens.body.copyWith(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child:
                    _FactTile(label: 'Quantity', value: '${detail.quantity}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FactTile(
                  label: 'Preferred Completion',
                  value: formattedCompletion ?? 'No preference',
                ),
              ),
            ],
          ),
          if (detail.subcategoryLabels.isNotEmpty) ...[
            const SizedBox(height: 14),
            _Label('Fabrication types'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final label in detail.subcategoryLabels)
                  RC5Chip(label: label, compact: true, isSelected: true),
              ],
            ),
          ],
          if (detail.needsDesignSupport || detail.needsMaterialProcurement) ...[
            const SizedBox(height: 14),
            _Label('Design & material'),
            const SizedBox(height: 6),
            if (detail.needsDesignSupport)
              const _BulletLine('Design support requested'),
            if (detail.needsMaterialProcurement) ...[
              const _BulletLine('Material procurement requested'),
              if (detail.materialNotes.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 2),
                  child: Text(
                    detail.materialNotes,
                    style: RC5DesignTokens.body.copyWith(
                      fontSize: 12,
                      color: RC5DesignTokens.textSecondary,
                    ),
                  ),
                ),
            ],
          ],
          if (detail.coarseQueuePosition != null) ...[
            const SizedBox(height: 14),
            _Label('Queue'),
            const SizedBox(height: 4),
            Text(
              detail.coarseQueuePosition!,
              style: RC5DesignTokens.body.copyWith(fontSize: 13),
            ),
          ],
          const SizedBox(height: 14),
          _Label('Machine assignment'),
          const SizedBox(height: 4),
          Text(
            detail.machineAssignmentLabel ?? 'Machine assignment pending',
            style: RC5DesignTokens.body.copyWith(
              fontSize: 13,
              color: RC5DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _Label('Payment'),
          const SizedBox(height: 4),
          Text(
            detail.paymentStateLabel ?? 'Not yet quoted',
            style: RC5DesignTokens.body.copyWith(
              fontSize: 13,
              color: RC5DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: RC5DesignTokens.body.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 11,
        color: RC5DesignTokens.textSecondary,
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 2),
        Text(
          value,
          style: RC5DesignTokens.body.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  const _BulletLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•  ', style: RC5DesignTokens.body.copyWith(fontSize: 13)),
          Expanded(
            child:
                Text(text, style: RC5DesignTokens.body.copyWith(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
