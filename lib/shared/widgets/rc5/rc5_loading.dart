import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';

class RC5Loading extends StatelessWidget {
  const RC5Loading({
    super.key,
    this.label = 'Loading',
    this.size = 24,
  });

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(
                RC5DesignTokens.ink,
              ),
            ),
          ),
          const SizedBox(height: RC5DesignTokens.space3),
          Text(
            label,
            style: RC5DesignTokens.body.copyWith(
              color: RC5DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
