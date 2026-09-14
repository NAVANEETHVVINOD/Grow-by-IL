import 'package:flutter/material.dart';

import '../../../../core/theme/rc5_design_tokens.dart';
import '../../models/work_request_detail.dart';

class WorkRequestDetailHeader extends StatelessWidget {
  const WorkRequestDetailHeader({
    super.key,
    required this.detail,
    required this.onBack,
  });

  final WorkRequestDetail detail;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Back to Work Requests',
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: RC5DesignTokens.border,
                      width: RC5DesignTokens.borderWidth,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: RC5DesignTokens.ink,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          detail.title,
          style: RC5DesignTokens.hero.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          'Request #${detail.id}',
          style: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
