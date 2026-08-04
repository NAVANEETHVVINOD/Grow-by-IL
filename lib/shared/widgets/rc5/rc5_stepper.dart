import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';

class RC5Stepper extends StatelessWidget {
  const RC5Stepper({
    super.key,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.stepLabel,
  });

  final int currentStepIndex;
  final int totalSteps;
  final String stepLabel;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStepIndex + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step ${currentStepIndex + 1} of $totalSteps',
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w800,
                color: RC5DesignTokens.textSecondary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              stepLabel,
              style: RC5DesignTokens.body.copyWith(
                fontWeight: FontWeight.w900,
                color: RC5DesignTokens.ink,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: RC5DesignTokens.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: RC5DesignTokens.border,
                  width: 1.5,
                ),
              ),
            ),
            AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              widthFactor: progress,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: RC5DesignTokens.primary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: RC5DesignTokens.ink,
                    width: 1.5,
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
