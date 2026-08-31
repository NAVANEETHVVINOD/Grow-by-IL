import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../utils/work_request_validators.dart';

class BasicsStepView extends ConsumerStatefulWidget {
  const BasicsStepView({super.key});

  @override
  ConsumerState<BasicsStepView> createState() => _BasicsStepViewState();
}

class _BasicsStepViewState extends ConsumerState<BasicsStepView> {
  late final TextEditingController _titleController;
  late final TextEditingController _purposeController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(workRequestCreateControllerProvider).draft;
    _titleController = TextEditingController(text: draft.title);
    _purposeController = TextEditingController(text: draft.purpose);
    _descriptionController = TextEditingController(text: draft.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _purposeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.draft),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us the basics',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Give core team and Machine Heads clear context before review.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        _TextInput(
          label: 'Request title',
          hint: 'e.g. Quadcopter chassis prototype',
          controller: _titleController,
          errorText: WorkRequestValidators.title(draft.title),
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(title: value),
          ),
        ),
        _TextInput(
          label: 'Purpose / Reason',
          hint: 'e.g. Mini project, Robocon contest, Lab personal build',
          controller: _purposeController,
          errorText: WorkRequestValidators.purpose(draft.purpose),
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(purpose: value),
          ),
        ),
        _TextInput(
          label: 'Detailed description',
          hint:
              'Describe your material requirements, dimensions, safety considerations, or design specs (min 20 chars)...',
          controller: _descriptionController,
          maxLines: 4,
          errorText: WorkRequestValidators.description(draft.description),
          helperText: '${draft.description.trim().length} / 2000 characters',
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(description: value),
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.maxLines = 1,
    this.errorText,
    this.helperText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? errorText;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: RC5DesignTokens.body.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: RC5DesignTokens.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: onChanged,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.ink,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: RC5DesignTokens.body.copyWith(
                color: RC5DesignTokens.textSecondary.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              errorText: errorText,
              helperText: helperText,
              helperStyle: RC5DesignTokens.body.copyWith(
                fontSize: 11,
                color: RC5DesignTokens.textSecondary,
              ),
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
        ],
      ),
    );
  }
}
