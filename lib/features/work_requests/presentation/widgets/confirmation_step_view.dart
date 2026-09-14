import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/rc5_design_tokens.dart';
import '../../../../shared/widgets/rc5/rc5_widgets.dart';

class ConfirmationStepView extends StatelessWidget {
  const ConfirmationStepView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: RC5DesignTokens.accent,
            shape: BoxShape.circle,
            border: Border.all(
              color: RC5DesignTokens.ink,
              width: 3,
            ),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 48,
            color: RC5DesignTokens.ink,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Request Created!',
          style: RC5DesignTokens.hero.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your local mock request has been created successfully. Phase 2 will enable cloud sync and Machine Head queue routing.',
            textAlign: TextAlign.center,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 30),
        RC5Button(
          label: 'Return to Work Requests',
          onPressed: () => context.go('/work-requests'),
        ),
      ],
    );
  }
}
