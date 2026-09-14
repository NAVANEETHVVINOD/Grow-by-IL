import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../constants/work_request_options.dart';
import 'rc5_date_tile.dart';

class ReviewStepView extends ConsumerWidget {
  const ReviewStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.draft),
    );
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    // Resolve subcategory ids back to their display labels.
    final subcategoryLabels = WorkRequestOptions.fabricationSubcategories
        .where((s) => draft.subcategoryIds.contains(s.id))
        .map((s) => s.label)
        .toList();

    // The primary design file link is the first element of externalLinks.
    final primaryLink = draft.externalLinks.firstOrNull ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Preferred Date',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Verify all details before submitting your local fabrication request.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        RC5DateTile(
          date: draft.preferredCompletionDate,
          onPickDate: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: draft.preferredCompletionDate ??
                  now.add(const Duration(days: 3)),
              firstDate: now,
              lastDate: now.add(const Duration(days: 180)),
            );
            if (picked != null) {
              controller.updateDraft(
                draft.copyWith(preferredCompletionDate: picked),
              );
            }
          },
          onClearDate: () => controller.updateDraft(
            draft.copyWith(clearPreferredCompletionDate: true),
          ),
        ),
        const SizedBox(height: 16),
        RC5Card(
          padding: const EdgeInsets.all(16),
          radius: 18,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Summary',
                style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
              ),
              const Divider(height: 24, color: RC5DesignTokens.border),
              const _SummaryRow(label: 'Category', value: 'Fabrication'),
              _SummaryRow(label: 'Title', value: draft.title),
              _SummaryRow(label: 'Purpose', value: draft.purpose),
              _SummaryRow(
                label: 'Processes',
                value: subcategoryLabels.isEmpty
                    ? 'None selected'
                    : subcategoryLabels.join(', '),
              ),
              _SummaryRow(label: 'Quantity', value: '${draft.quantity} units'),
              _SummaryRow(label: 'Priority', value: draft.priority.label),
              _SummaryRow(
                label: 'Team',
                value: draft.memberNames.isEmpty
                    ? 'Solo request'
                    : draft.memberNames.join(', '),
              ),
              if (primaryLink.isNotEmpty)
                _SummaryRow(label: 'CAD Link', value: primaryLink),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: RC5DesignTokens.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: RC5DesignTokens.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
