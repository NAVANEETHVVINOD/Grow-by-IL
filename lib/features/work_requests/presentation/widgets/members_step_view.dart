import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';

class MembersStepView extends ConsumerStatefulWidget {
  const MembersStepView({super.key});

  @override
  ConsumerState<MembersStepView> createState() => _MembersStepViewState();
}

class _MembersStepViewState extends ConsumerState<MembersStepView> {
  late final TextEditingController _memberInputController;

  @override
  void initState() {
    super.initState();
    _memberInputController = TextEditingController();
  }

  @override
  void dispose() {
    _memberInputController.dispose();
    super.dispose();
  }

  void _addMember() {
    final text = _memberInputController.text.trim();
    if (text.isEmpty) return;

    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = ref.read(workRequestCreateControllerProvider).draft;
    final list = List<String>.from(draft.memberNames);
    if (!list.contains(text)) {
      list.add(text);
      controller.updateDraft(draft.copyWith(memberNames: list));
    }
    _memberInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.draft),
    );
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Team Collaborators',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Add team members or lab collaborators working on this request.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _memberInputController,
                onSubmitted: (_) => _addMember(),
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RC5DesignTokens.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter student ID or name...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: RC5DesignTokens.border,
                      width: RC5DesignTokens.borderWidth,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: RC5DesignTokens.border,
                      width: RC5DesignTokens.borderWidth,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: RC5DesignTokens.ink,
                      width: RC5DesignTokens.borderWidth + 0.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            RC5Card(
              onTap: _addMember,
              backgroundColor: RC5DesignTokens.ink,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              radius: 16,
              child: Text(
                'Add',
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (draft.memberNames.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'No team members added yet. Add yourself or teammates.',
                style: RC5DesignTokens.body.copyWith(
                  color: RC5DesignTokens.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final member in draft.memberNames)
                Chip(
                  label: Text(
                    member,
                    style: RC5DesignTokens.body.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  onDeleted: () {
                    final list = List<String>.from(draft.memberNames)
                      ..remove(member);
                    controller.updateDraft(draft.copyWith(memberNames: list));
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: RC5DesignTokens.border,
                      width: RC5DesignTokens.borderWidth,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
