import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../utils/work_request_validators.dart';

class DesignMaterialStepView extends ConsumerStatefulWidget {
  const DesignMaterialStepView({super.key});

  @override
  ConsumerState<DesignMaterialStepView> createState() =>
      _DesignMaterialStepViewState();
}

class _DesignMaterialStepViewState
    extends ConsumerState<DesignMaterialStepView> {
  late final TextEditingController _linkController;
  late final TextEditingController _materialNotesController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(workRequestCreateControllerProvider).draft;
    // externalLinks is a list; show the first link (design file) in this field.
    _linkController =
        TextEditingController(text: draft.externalLinks.firstOrNull ?? '');
    _materialNotesController = TextEditingController(text: draft.materialNotes);
  }

  @override
  void dispose() {
    _linkController.dispose();
    _materialNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.draft),
    );
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    // The first element of externalLinks is treated as the primary design file link.
    final primaryLink = draft.externalLinks.firstOrNull ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Design & Material Notes',
          style: RC5DesignTokens.sectionTitle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 6),
        Text(
          'Attach CAD/STL links and specify material sourcing preferences.',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Design file link (Google Drive / GitHub / Onshape)',
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _linkController,
                onChanged: (val) {
                  // Update the first element of externalLinks with the new value.
                  final trimmed = val.trim();
                  final updated = trimmed.isEmpty
                      ? const <String>[]
                      : [trimmed, ...draft.externalLinks.skip(1)];
                  controller.updateDraft(
                    draft.copyWith(externalLinks: updated),
                  );
                },
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: RC5DesignTokens.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'https://drive.google.com/file/...',
                  errorText: primaryLink.isNotEmpty
                      ? WorkRequestValidators.externalLink(primaryLink)
                      : null,
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
                ),
              ),
            ],
          ),
        ),
        _SwitchTile(
          title: 'Request design / CAD review support',
          subtitle:
              'Check if you need a mentor to review your 3D model before printing.',
          value: draft.needsDesignSupport,
          onChanged: (val) => controller.updateDraft(
            draft.copyWith(needsDesignSupport: val),
          ),
        ),
        const SizedBox(height: 12),
        _SwitchTile(
          title: 'Request lab material procurement',
          subtitle:
              'Check if you need lab stock PLA/Acrylic instead of bringing your own.',
          value: draft.needsMaterialProcurement,
          onChanged: (val) => controller.updateDraft(
            draft.copyWith(needsMaterialProcurement: val),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Material & dimensions notes',
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _materialNotesController,
              maxLines: 3,
              onChanged: (val) => controller.updateDraft(
                draft.copyWith(materialNotes: val),
              ),
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w700,
                color: RC5DesignTokens.ink,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. 15% infill PLA, 3mm clear acrylic sheet...',
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
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      padding: const EdgeInsets.all(14),
      radius: 16,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RC5DesignTokens.body.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: RC5DesignTokens.body.copyWith(
                    fontSize: 11,
                    color: RC5DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: RC5DesignTokens.ink,
            activeTrackColor: RC5DesignTokens.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
