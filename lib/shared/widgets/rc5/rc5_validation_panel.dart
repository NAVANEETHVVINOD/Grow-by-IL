import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';
import 'rc5_widgets.dart';

class RC5ValidationPanel extends StatelessWidget {
  const RC5ValidationPanel({
    super.key,
    required this.errors,
  });

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RC5Card(
        backgroundColor: const Color(0xFFFFD6D6),
        padding: const EdgeInsets.all(14),
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: RC5DesignTokens.ink,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Please fix the following issues:',
                  style: RC5DesignTokens.body.copyWith(
                    fontWeight: FontWeight.w900,
                    color: RC5DesignTokens.ink,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final error in errors)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        error,
                        style: RC5DesignTokens.body.copyWith(
                          fontSize: 12,
                          color: RC5DesignTokens.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
