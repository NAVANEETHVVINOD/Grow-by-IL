import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../constants/work_request_options.dart';

class FabricationStepView extends ConsumerWidget {
  const FabricationStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.draft),
    );
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fabrication Details',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Select machine processes, required quantity, and priority.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Subcategory Processes',
          style: RC5DesignTokens.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final sub in WorkRequestOptions.fabricationSubcategories)
              _SubcategoryChip(
                label: sub.label,
                isSelected: draft.subcategoryIds.contains(sub.id),
                onTap: () {
                  final list = List<String>.from(draft.subcategoryIds);
                  if (list.contains(sub.id)) {
                    list.remove(sub.id);
                  } else {
                    list.add(sub.id);
                  }
                  controller.updateDraft(draft.copyWith(subcategoryIds: list));
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quantity required',
                    style: RC5DesignTokens.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Number of physical units',
                    style: RC5DesignTokens.body.copyWith(
                      fontSize: 11,
                      color: RC5DesignTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            _QuantitySelector(
              quantity: draft.quantity,
              onChanged: (qty) => controller.updateDraft(
                draft.copyWith(quantity: qty),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Priority level',
          style: RC5DesignTokens.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final prio in WorkRequestPriority.values) ...[
              Expanded(
                child: _PriorityChip(
                  label: prio.label,
                  isSelected: draft.priority == prio,
                  onTap: () => controller.updateDraft(
                    draft.copyWith(priority: prio),
                  ),
                ),
              ),
              if (prio != WorkRequestPriority.values.last)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _SubcategoryChip extends StatelessWidget {
  const _SubcategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: '$label fabrication process',
      child: RC5Card(
        onTap: onTap,
        backgroundColor: isSelected ? RC5DesignTokens.ink : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        radius: 14,
        child: Text(
          label,
          style: RC5DesignTokens.body.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isSelected ? Colors.white : RC5DesignTokens.ink,
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RC5DesignTokens.border,
          width: RC5DesignTokens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease quantity',
            icon: const Icon(Icons.remove_rounded, size: 18),
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Increase quantity',
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: quantity < 100 ? () => onChanged(quantity + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: '$label priority',
      child: RC5Card(
        onTap: onTap,
        backgroundColor: isSelected ? RC5DesignTokens.accent : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        radius: 14,
        child: Center(
          child: Text(
            label,
            style: RC5DesignTokens.body.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: RC5DesignTokens.ink,
            ),
          ),
        ),
      ),
    );
  }
}
