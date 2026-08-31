import 'package:flutter/material.dart';

import '../../../../shared/widgets/rc5/rc5_widgets.dart';

class WorkRequestCollaboratorsSection extends StatelessWidget {
  const WorkRequestCollaboratorsSection({
    super.key,
    required this.leaderName,
    required this.collaboratorNames,
  });

  final String? leaderName;
  final List<String> collaboratorNames;

  @override
  Widget build(BuildContext context) {
    if (leaderName == null && collaboratorNames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (leaderName != null)
          Semantics(
            label: 'Leader: $leaderName',
            child: RC5Chip(
              label: leaderName!,
              icon: Icons.star_rounded,
              isSelected: true,
            ),
          ),
        for (final name in collaboratorNames)
          Semantics(
            label: 'Collaborator: $name',
            child: RC5Chip(label: name, icon: Icons.person_outline_rounded),
          ),
      ],
    );
  }
}
