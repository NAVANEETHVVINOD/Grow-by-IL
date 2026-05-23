import 'package:flutter/material.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

class RC5Avatar extends StatelessWidget {
  const RC5Avatar({
    super.key,
    this.imageUrl,
    this.displayName,
    this.username,
    this.size = 56,
    this.showBorder = true,
  });

  final String? imageUrl;
  final String? displayName;
  final String? username;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(displayName ?? username ?? 'Grow');
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: RC5DesignTokens.ink,
                width: RC5DesignTokens.borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? RC5DesignTokens.neoShadow(
                opacity: 0.9,
                offset: const Offset(2, 2),
              )
            : null,
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackAvatar(
                  initials: initials,
                  size: size,
                ),
              )
            : _FallbackAvatar(initials: initials, size: size),
      ),
    );
  }

  String _initials(String source) {
    final words = source
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'G';
    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration:
          const BoxDecoration(gradient: RC5DesignTokens.primaryGradient),
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontSize: size * 0.34,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}
