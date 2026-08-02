import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../../constants/work_request_options.dart';
import '../../utils/work_request_validators.dart';

class CreateWorkRequestScreen extends ConsumerWidget {
  const CreateWorkRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: state.isRestoring
            ? const _LoadingDraft()
            : Column(
                children: [
                  _WizardHeader(
                    state: state,
                    onBack: () {
                      if (state.canGoBack) {
                        controller.previousStep();
                      } else {
                        context.pop();
                      }
                    },
                    onStepTap: controller.goToStep,
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
                      children: [
                        _ValidationPanel(errors: state.validationErrors),
                        _ErrorPanel(message: state.lastError),
                        _StepBody(state: state),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: state.isRestoring
          ? null
          : _BottomActions(
              state: state,
              onBack: controller.previousStep,
              onNext: () async {
                if (state.currentStep == WorkRequestCreateStep.review) {
                  await controller.submitMockRequest();
                  return;
                }
                await controller.nextStep();
              },
              onClear: () async {
                final shouldClear = await _confirmClearDraft(context);
                if (shouldClear && context.mounted) {
                  await controller.clearDraft();
                }
              },
            ),
    );
  }

  Future<bool> _confirmClearDraft(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Clear draft?'),
            content: const Text(
              'This only clears the local device draft. Nothing has been sent.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _LoadingDraft extends StatelessWidget {
  const _LoadingDraft();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RC5Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: RC5DesignTokens.ink),
            const SizedBox(height: 16),
            Text('Restoring local draft', style: RC5DesignTokens.cardTitle),
          ],
        ),
      ),
    );
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({
    required this.state,
    required this.onBack,
    required this.onStepTap,
  });

  final WorkRequestCreateState state;
  final VoidCallback onBack;
  final ValueChanged<WorkRequestCreateStep> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(color: RC5DesignTokens.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RC5Card(
                onTap: onBack,
                padding: EdgeInsets.zero,
                radius: 16,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.arrow_back_rounded),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Work Request',
                      style: RC5DesignTokens.cardTitle.copyWith(fontSize: 20),
                    ),
                    Text(
                      'Local draft only - no Supabase submit',
                      style: RC5DesignTokens.body.copyWith(
                        color: RC5DesignTokens.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.isSaving)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RC5DesignTokens.ink,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 9,
              color: RC5DesignTokens.ink,
              backgroundColor: RC5DesignTokens.primary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final step in WorkRequestCreateStep.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: RC5Chip(
                      label: step.label,
                      compact: true,
                      isSelected: step == state.currentStep,
                      onTap: () => onStepTap(step),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBody extends ConsumerWidget {
  const _StepBody({required this.state});

  final WorkRequestCreateState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: RC5DesignTokens.motionBase,
      child: switch (state.currentStep) {
        WorkRequestCreateStep.category => const _CategoryStep(),
        WorkRequestCreateStep.basics => const _BasicsStep(),
        WorkRequestCreateStep.fabrication => const _FabricationStep(),
        WorkRequestCreateStep.members => const _MembersStep(),
        WorkRequestCreateStep.designMaterial => const _DesignMaterialStep(),
        WorkRequestCreateStep.review => const _ReviewStep(),
        WorkRequestCreateStep.confirmation => const _ConfirmationStep(),
      },
    );
  }
}

class _CategoryStep extends ConsumerWidget {
  const _CategoryStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'What kind of help do you need?',
      subtitle: 'Fabrication is live first. The rest stay visible as roadmap.',
      icon: Icons.category_rounded,
      children: [
        for (final category in WorkRequestOptions.categories) ...[
          _CategoryOptionTile(category: category),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Text('Fabrication type', style: RC5DesignTokens.cardTitle),
        const SizedBox(height: 12),
        for (final option in WorkRequestOptions.fabricationSubcategories)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SelectableTile(
              title: option.label,
              subtitle: option.description,
              icon: option.icon,
              selected: draft.subcategoryIds.contains(option.id),
              onTap: () {
                final next = [...draft.subcategoryIds];
                if (next.contains(option.id)) {
                  next.remove(option.id);
                } else {
                  next.add(option.id);
                }
                controller.updateDraft(draft.copyWith(subcategoryIds: next));
              },
            ),
          ),
      ],
    );
  }
}

class _BasicsStep extends ConsumerWidget {
  const _BasicsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'Tell us the basics',
      subtitle: 'Give the machine team enough context to review the work.',
      icon: Icons.edit_note_rounded,
      children: [
        _TextInput(
          label: 'Request title',
          initialValue: draft.title,
          textInputAction: TextInputAction.next,
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(title: value),
          ),
        ),
        _TextInput(
          label: 'Purpose / reason',
          initialValue: draft.purpose,
          textInputAction: TextInputAction.next,
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(purpose: value),
          ),
        ),
        _TextInput(
          label: 'Description',
          initialValue: draft.description,
          maxLines: 5,
          helperText: 'Minimum 20 characters, recommended max 2000.',
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(description: value),
          ),
        ),
        _QuantitySelector(
          value: draft.quantity,
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(quantity: value),
          ),
        ),
      ],
    );
  }
}

class _FabricationStep extends ConsumerWidget {
  const _FabricationStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'Timeline and files',
      subtitle: 'Links stay external for now to protect Supabase storage.',
      icon: Icons.event_note_rounded,
      children: [
        Text('Priority', style: RC5DesignTokens.cardTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final priority in WorkRequestPriority.values)
              RC5Chip(
                label: priority.label,
                isSelected: priority == draft.priority,
                onTap: () => controller.updateDraft(
                  draft.copyWith(priority: priority),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Lab preference', style: RC5DesignTokens.cardTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lab in WorkRequestLabPreference.values)
              RC5Chip(
                label: lab.label,
                isSelected: lab == draft.labPreference,
                onTap: () => controller.updateDraft(
                  draft.copyWith(labPreference: lab),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _DateTile(
          date: draft.preferredCompletionDate,
          onPick: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              initialDate: draft.preferredCompletionDate ?? DateTime.now(),
            );
            if (picked != null) {
              await controller.updateDraft(
                draft.copyWith(preferredCompletionDate: picked),
              );
            }
          },
          onClear: () => controller.updateDraft(
            draft.copyWith(clearPreferredCompletionDate: true),
          ),
        ),
        _EditableStringList(
          title: 'External file links',
          subtitle: 'Drive, GitHub, Dropbox, OneDrive, or similar.',
          emptyText: 'No file links added yet.',
          values: draft.externalLinks,
          inputLabel: 'Paste a file link',
          onAdd: (value) {
            final error = WorkRequestValidators.externalLink(value);
            if (error != null) return error;
            controller.updateDraft(
              draft.copyWith(externalLinks: [...draft.externalLinks, value]),
            );
            return null;
          },
          onRemove: (value) => controller.updateDraft(
            draft.copyWith(
              externalLinks:
                  draft.externalLinks.where((item) => item != value).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _MembersStep extends ConsumerWidget {
  const _MembersStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'Add collaborators',
      subtitle:
          'Optional now. Editable while draft, submitted, or changes requested.',
      icon: Icons.group_add_rounded,
      children: [
        _EditableStringList(
          title: 'Members',
          subtitle: 'Names are local draft text in this UI-only phase.',
          emptyText: 'No members added.',
          values: draft.memberNames,
          inputLabel: 'Member name',
          onAdd: (value) {
            if (value.trim().length < 2) return 'Enter a member name.';
            controller.updateDraft(
              draft.copyWith(memberNames: [...draft.memberNames, value]),
            );
            return null;
          },
          onRemove: (value) => controller.updateDraft(
            draft.copyWith(
              memberNames:
                  draft.memberNames.where((item) => item != value).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesignMaterialStep extends ConsumerWidget {
  const _DesignMaterialStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'Design and material support',
      subtitle: 'Tell the team whether they need to design or source anything.',
      icon: Icons.build_circle_rounded,
      children: [
        _SwitchTile(
          title: 'Needs design support',
          subtitle:
              'Core team may design or repair the file before fabrication.',
          value: draft.needsDesignSupport,
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(needsDesignSupport: value),
          ),
        ),
        _SwitchTile(
          title: 'Needs material procurement',
          subtitle: 'Materials may affect quote and timeline.',
          value: draft.needsMaterialProcurement,
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(needsMaterialProcurement: value),
          ),
        ),
        if (draft.needsMaterialProcurement)
          _TextInput(
            label: 'Material notes',
            initialValue: draft.materialNotes,
            maxLines: 4,
            onChanged: (value) => controller.updateDraft(
              draft.copyWith(materialNotes: value),
            ),
          ),
      ],
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workRequestCreateControllerProvider);
    final controller = ref.read(workRequestCreateControllerProvider.notifier);
    final draft = state.draft;

    return _StepCard(
      title: 'Review and confirm',
      subtitle: 'This mock submit clears only the local draft.',
      icon: Icons.fact_check_rounded,
      children: [
        _ReviewTile(label: 'Title', value: draft.title),
        _ReviewTile(label: 'Purpose', value: draft.purpose),
        _ReviewTile(label: 'Description', value: draft.description),
        _ReviewTile(label: 'Quantity', value: '${draft.quantity}'),
        _ReviewTile(label: 'Priority', value: draft.priority.label),
        _ReviewTile(label: 'Lab preference', value: draft.labPreference.label),
        _ReviewTile(
          label: 'Subcategories',
          value: draft.subcategoryIds.isEmpty
              ? 'None'
              : draft.subcategoryIds.join(', '),
        ),
        _ReviewTile(
          label: 'Preferred completion',
          value: draft.preferredCompletionDate == null
              ? 'Not set'
              : DateFormat.yMMMd().format(draft.preferredCompletionDate!),
        ),
        _ReviewTile(
          label: 'Members',
          value:
              draft.memberNames.isEmpty ? 'None' : draft.memberNames.join(', '),
        ),
        _ReviewTile(
          label: 'External links',
          value: draft.externalLinks.isEmpty
              ? 'None'
              : '${draft.externalLinks.length} link(s)',
        ),
        const SizedBox(height: 12),
        _ConsentCheck(
          value: draft.safetyAcknowledged,
          label: 'I agree to follow safety and community guidelines.',
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(safetyAcknowledged: value),
          ),
        ),
        _ConsentCheck(
          value: draft.editApprovalAcknowledged,
          label:
              'I understand the core team may suggest edits before work starts.',
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(editApprovalAcknowledged: value),
          ),
        ),
        _ConsentCheck(
          value: draft.reviewSummaryConfirmed,
          label: 'I confirm this summary is ready for local mock submit.',
          onChanged: (value) => controller.updateDraft(
            draft.copyWith(reviewSummaryConfirmed: value),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationStep extends ConsumerWidget {
  const _ConfirmationStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return _StepCard(
      title: 'Draft submitted locally',
      subtitle: 'No server write happened. This is a UI-only confirmation.',
      icon: Icons.check_circle_rounded,
      children: [
        const Icon(
          Icons.rocket_launch_rounded,
          size: 58,
          color: RC5DesignTokens.ink,
        ),
        const SizedBox(height: 16),
        Text(
          'Your request flow is ready for student testing. Backend submission arrives after Phase 2 ERD/RLS approval.',
          textAlign: TextAlign.center,
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        RC5Button(
          label: 'Start another local draft',
          icon: Icons.add_rounded,
          fullWidth: true,
          onPressed: controller.clearDraft,
        ),
      ],
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.state,
    required this.onBack,
    required this.onNext,
    required this.onClear,
  });

  final WorkRequestCreateState state;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (state.currentStep == WorkRequestCreateStep.confirmation) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        decoration: BoxDecoration(
          color: RC5DesignTokens.background.withValues(alpha: 0.96),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            if (state.canGoBack)
              Expanded(
                child: RC5Button(
                  label: 'Back',
                  icon: Icons.arrow_back_rounded,
                  variant: RC5ButtonVariant.secondary,
                  onPressed: onBack,
                ),
              )
            else
              Expanded(
                child: RC5Button(
                  label: 'Clear',
                  icon: Icons.delete_outline_rounded,
                  variant: RC5ButtonVariant.ghost,
                  onPressed: onClear,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: RC5Button(
                label: state.currentStep == WorkRequestCreateStep.review
                    ? 'Mock submit'
                    : 'Continue',
                icon: state.currentStep == WorkRequestCreateStep.review
                    ? Icons.check_rounded
                    : Icons.arrow_forward_rounded,
                isLoading: state.isSaving,
                onPressed: onNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      key: ValueKey(title),
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: RC5DesignTokens.primary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: RC5DesignTokens.ink,
                    width: RC5DesignTokens.borderWidth,
                  ),
                ),
                child: Icon(icon, color: RC5DesignTokens.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: RC5DesignTokens.sectionTitle),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: RC5DesignTokens.body.copyWith(
                        color: RC5DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _CategoryOptionTile extends StatelessWidget {
  const _CategoryOptionTile({required this.category});

  final WorkRequestCategoryOption category;

  @override
  Widget build(BuildContext context) {
    return _SelectableTile(
      title: category.label,
      subtitle: category.enabled
          ? category.description
          : '${category.description} Coming soon.',
      icon: category.icon,
      selected: category.enabled,
      disabled: !category.enabled,
      trailing: category.enabled
          ? const Icon(Icons.check_circle_rounded, color: RC5DesignTokens.ink)
          : const _ComingSoonPill(),
      onTap: category.enabled ? () {} : null,
    );
  }
}

class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    this.disabled = false,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final bool disabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      onTap: disabled ? null : onTap,
      enablePressEffect: !disabled,
      shadowOpacity: disabled ? 0.2 : 0.8,
      backgroundColor: selected ? RC5DesignTokens.primary : Colors.white,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(
            icon,
            color: disabled ? RC5DesignTokens.muted : RC5DesignTokens.ink,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RC5DesignTokens.cardTitle.copyWith(
                    color: disabled
                        ? RC5DesignTokens.textSecondary
                        : RC5DesignTokens.ink,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: RC5DesignTokens.body.copyWith(
                    color: RC5DesignTokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ComingSoonPill extends StatelessWidget {
  const _ComingSoonPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: RC5DesignTokens.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: RC5DesignTokens.ink, width: 1.5),
      ),
      child: Text(
        'Coming soon',
        style: RC5DesignTokens.body.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.helperText,
    this.maxLines = 1,
    this.textInputAction,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? helperText;
  final int maxLines;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        textInputAction: textInputAction,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          filled: true,
          fillColor: RC5DesignTokens.background,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: RC5DesignTokens.ink, width: 2.5),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return RC5Card(
      padding: const EdgeInsets.all(14),
      backgroundColor: RC5DesignTokens.accent,
      shadowOpacity: 0.6,
      child: Row(
        children: [
          Expanded(
            child: Text('Quantity', style: RC5DesignTokens.cardTitle),
          ),
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Text(
            '$value',
            style: RC5DesignTokens.cardTitle.copyWith(fontSize: 22),
          ),
          IconButton(
            onPressed: () => onChanged(value + 1),
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.date,
    required this.onPick,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RC5Card(
        onTap: onPick,
        padding: const EdgeInsets.all(14),
        backgroundColor: RC5DesignTokens.success,
        shadowOpacity: 0.6,
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null
                    ? 'Preferred completion date'
                    : DateFormat.yMMMd().format(date!),
                style: RC5DesignTokens.cardTitle.copyWith(fontSize: 16),
              ),
            ),
            if (date != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
          ],
        ),
      ),
    );
  }
}

class _EditableStringList extends StatefulWidget {
  const _EditableStringList({
    required this.title,
    required this.subtitle,
    required this.emptyText,
    required this.values,
    required this.inputLabel,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final String emptyText;
  final List<String> values;
  final String inputLabel;
  final String? Function(String value) onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<_EditableStringList> createState() => _EditableStringListState();
}

class _EditableStringListState extends State<_EditableStringList> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: RC5DesignTokens.cardTitle),
        const SizedBox(height: 4),
        Text(
          widget.subtitle,
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: widget.inputLabel,
                  errorText: _error,
                  filled: true,
                  fillColor: RC5DesignTokens.background,
                  border: _inputBorder(),
                  enabledBorder: _inputBorder(),
                  focusedBorder: _inputBorder(
                    color: RC5DesignTokens.ink,
                    width: 2.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 52,
              height: 52,
              child: RC5Button(
                label: '',
                icon: Icons.add_rounded,
                onPressed: () {
                  final value = _controller.text.trim();
                  final error = widget.onAdd(value);
                  setState(() => _error = error);
                  if (error == null) _controller.clear();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.values.isEmpty)
          Text(
            widget.emptyText,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in widget.values)
                InputChip(
                  label: Text(value),
                  onDeleted: () => widget.onRemove(value),
                  backgroundColor: RC5DesignTokens.primary,
                  side: const BorderSide(
                    color: RC5DesignTokens.ink,
                    width: 1.5,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RC5Card(
        padding: const EdgeInsets.all(14),
        backgroundColor: value ? RC5DesignTokens.primary : Colors.white,
        shadowOpacity: 0.6,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RC5DesignTokens.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: RC5DesignTokens.body.copyWith(
                      color: RC5DesignTokens.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: RC5DesignTokens.ink,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentCheck extends StatelessWidget {
  const _ConsentCheck({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: (next) => onChanged(next ?? false),
      title: Text(label, style: RC5DesignTokens.body),
      activeColor: RC5DesignTokens.ink,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
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
            width: 112,
            child: Text(
              label,
              style: RC5DesignTokens.body.copyWith(
                color: RC5DesignTokens.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? 'Not set' : value,
              style: RC5DesignTokens.body.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationPanel extends StatelessWidget {
  const _ValidationPanel({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RC5Card(
        backgroundColor: const Color(0xFFFFD6D6),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fix before continuing', style: RC5DesignTokens.cardTitle),
            const SizedBox(height: 8),
            for (final error in errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('- $error', style: RC5DesignTokens.body),
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: RC5Card(
        backgroundColor: const Color(0xFFFFD6D6),
        padding: const EdgeInsets.all(14),
        child: Text(message!, style: RC5DesignTokens.body),
      ),
    );
  }
}

OutlineInputBorder _inputBorder({
  Color color = RC5DesignTokens.border,
  double width = RC5DesignTokens.borderWidth,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: width),
  );
}
