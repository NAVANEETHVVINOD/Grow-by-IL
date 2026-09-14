import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';

class CreateWorkRequestHeader extends ConsumerWidget {
  const CreateWorkRequestHeader({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStepIndex = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.currentStepIndex),
    );
    final totalSteps = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.totalSteps),
    );
    final stepLabel = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.currentStep.label),
    );
    final isSaving = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.isSaving),
    );

    return Column(
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
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: RC5DesignTokens.ink,
                  size: 22,
                ),
              ),
            ),
            const Spacer(),
            if (isSaving)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: RC5DesignTokens.ink,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: RC5DesignTokens.accent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: RC5DesignTokens.ink,
                  width: RC5DesignTokens.borderWidth,
                ),
              ),
              child: Text(
                'Local draft saved',
                style: RC5DesignTokens.body.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Create Work Request',
          style: RC5DesignTokens.hero.copyWith(fontSize: 30),
        ),
        const SizedBox(height: 14),
        RC5Stepper(
          currentStepIndex: currentStepIndex,
          totalSteps: totalSteps,
          stepLabel: stepLabel,
        ),
      ],
    );
  }
}
