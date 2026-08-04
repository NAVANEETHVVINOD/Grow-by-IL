import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';
import '../../application/providers/work_request_create_controller.dart';
import '../widgets/basics_step_view.dart';
import '../widgets/category_step_view.dart';
import '../widgets/confirmation_step_view.dart';
import '../widgets/create_work_request_header.dart';
import '../widgets/design_material_step_view.dart';
import '../widgets/fabrication_step_view.dart';
import '../widgets/members_step_view.dart';
import '../widgets/review_step_view.dart';

class CreateWorkRequestScreen extends ConsumerWidget {
  const CreateWorkRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.currentStep),
    );
    final canGoBack = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.canGoBack),
    );
    final isConfirmationStep = ref.watch(
      workRequestCreateControllerProvider
          .select((s) => s.currentStep == WorkRequestCreateStep.confirmation),
    );
    final validationErrors = ref.watch(
      workRequestCreateControllerProvider.select((s) => s.validationErrors),
    );
    final controller = ref.read(workRequestCreateControllerProvider.notifier);

    return Scaffold(
      backgroundColor: RC5DesignTokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CreateWorkRequestHeader(
                onBack: () {
                  if (!canGoBack) {
                    context.go('/work-requests');
                  } else {
                    controller.previousStep();
                  }
                },
              ),
              const SizedBox(height: 24),
              RC5ValidationPanel(errors: validationErrors),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey(currentStep),
                  child: _buildStepView(currentStep),
                ),
              ),
              const SizedBox(height: 30),
              if (!isConfirmationStep)
                Row(
                  children: [
                    if (canGoBack)
                      Expanded(
                        child: RC5Button(
                          label: 'Back',
                          variant: RC5ButtonVariant.secondary,
                          onPressed: () => controller.previousStep(),
                        ),
                      ),
                    if (canGoBack) const SizedBox(width: 12),
                    Expanded(
                      child: RC5Button(
                        label: currentStep == WorkRequestCreateStep.review
                            ? 'Submit Mock Request'
                            : 'Continue',
                        onPressed: () {
                          if (currentStep == WorkRequestCreateStep.review) {
                            controller.submitMockRequest();
                          } else {
                            controller.nextStep();
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepView(WorkRequestCreateStep step) {
    switch (step) {
      case WorkRequestCreateStep.category:
        return const CategoryStepView();
      case WorkRequestCreateStep.basics:
        return const BasicsStepView();
      case WorkRequestCreateStep.fabrication:
        return const FabricationStepView();
      case WorkRequestCreateStep.members:
        return const MembersStepView();
      case WorkRequestCreateStep.designMaterial:
        return const DesignMaterialStepView();
      case WorkRequestCreateStep.review:
        return const ReviewStepView();
      case WorkRequestCreateStep.confirmation:
        return const ConfirmationStepView();
    }
  }
}
