import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../constants/work_request_options.dart';

class CategoryStepView extends ConsumerWidget {
  const CategoryStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Phase 1: 'Fabrication' is the only enabled category and is always selected.
    // The category is not stored on WorkRequestDraft — the draft always implies Fabrication.
    const selectedCategory = 'Fabrication';
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What kind of help do you need?',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Phase 1 supports Fabrication requests. Other categories remain visible as V1 master data.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        for (final category in WorkRequestOptions.categories) ...[
          _CategoryOptionTile(
            category: category,
            isSelected: category.label == selectedCategory,
            onSelect: category.enabled
                ? () => controller.nextStep()
                : null,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _CategoryOptionTile extends StatelessWidget {
  const _CategoryOptionTile({
    required this.category,
    required this.isSelected,
    required this.onSelect,
  });

  final WorkRequestCategoryOption category;
  final bool isSelected;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final card = RC5Card(
      onTap: onSelect,
      backgroundColor: category.enabled
          ? (isSelected ? RC5DesignTokens.accent : Colors.white)
          : const Color(0xFFF3F4F6),
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.enabled ? Colors.white : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: RC5DesignTokens.border,
                width: RC5DesignTokens.borderWidth,
              ),
            ),
            child: Icon(
              category.icon,
              color: category.enabled
                  ? RC5DesignTokens.ink
                  : RC5DesignTokens.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category.label,
                      style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
                    ),
                    if (!category.enabled) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: RC5DesignTokens.border,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Coming soon',
                          style: RC5DesignTokens.body.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: RC5DesignTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  category.description,
                  style: RC5DesignTokens.body.copyWith(
                    color: RC5DesignTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            isSelected
                ? Icons.check_circle_rounded
                : Icons.arrow_forward_ios_rounded,
            color: isSelected
                ? RC5DesignTokens.ink
                : RC5DesignTokens.textSecondary.withValues(alpha: 0.5),
            size: isSelected ? 22 : 16,
          ),
        ],
      ),
    );

    return Semantics(
      selected: isSelected,
      enabled: category.enabled,
      label: '${category.label} category. ${category.description}',
      child: card,
    );
  }
}
