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
                cacheWidth: (size * 3).toInt(),
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

  Color _getColorForInitials(String str) {
    if (str.isEmpty) return const Color(0xFF2563EB); // Default blue
    final hash = str.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF16A34A), // Green
      const Color(0xFFD97706), // Amber
      const Color(0xFFDC2626), // Red
      const Color(0xFF9333EA), // Purple
      const Color(0xFF0D9488), // Teal
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[hash % colors.length];
  }

  IconData _getIconForInitials(String str) {
    if (str.isEmpty) return Icons.smart_toy_rounded;
    final hash = str.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    final icons = [
      Icons.smart_toy_rounded,         // Robot
      Icons.sports_esports_rounded,    // Gamer
      Icons.rocket_launch_rounded,     // Rocket
      Icons.auto_awesome_rounded,      // Sparkles
      Icons.construction_rounded,      // Builder
      Icons.brush_rounded,             // Designer
      Icons.science_rounded,           // Scientist
      Icons.lightbulb_outline_rounded, // Inventor
      Icons.psychology_rounded,        // Thinker
      Icons.videogame_asset_rounded,   // Retro arcade
    ];
    return icons[hash % icons.length];
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColorForInitials(initials);
    final iconData = _getIconForInitials(initials);

    return DecoratedBox(
      decoration: BoxDecoration(color: bgColor),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: size * 0.52,
        ),
      ),
    );
  }
}
