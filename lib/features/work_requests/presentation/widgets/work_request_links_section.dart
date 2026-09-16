import 'package:flutter/material.dart';

import '../../../../core/theme/rc5_design_tokens.dart';

class WorkRequestLinksSection extends StatelessWidget {
  const WorkRequestLinksSection({super.key, required this.links});

  final List<String> links;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              link: true,
              label: 'External design link: $link',
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    size: 16,
                    color: RC5DesignTokens.ink,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RC5DesignTokens.body.copyWith(
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                        color: RC5DesignTokens.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
