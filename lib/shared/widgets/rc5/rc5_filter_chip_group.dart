import 'package:flutter/material.dart';
import 'rc5_chip.dart';

class RC5FilterChipGroup<T> extends StatelessWidget {
  const RC5FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    required this.labelMapper,
  });

  final List<T> options;
  final T selectedOption;
  final ValueChanged<T> onSelected;
  final String Function(T option) labelMapper;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (final option in options) ...[
            _buildChip(option),
            if (option != options.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(T option) {
    final label = labelMapper(option);
    final isSelected = option == selectedOption;

    return Semantics(
      selected: isSelected,
      label: '$label filter option',
      button: true,
      child: RC5Chip(
        label: label,
        isSelected: isSelected,
        onTap: () => onSelected(option),
      ),
    );
  }
}
