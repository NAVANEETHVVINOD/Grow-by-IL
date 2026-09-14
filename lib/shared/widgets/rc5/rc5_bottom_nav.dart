import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

class RC5BottomNavItem {
  const RC5BottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.iconBuilder,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget Function(Color color, double size)? iconBuilder;
}

class RC5BottomNav extends StatelessWidget {
  const RC5BottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  }) : assert(items.length == 3, 'RC5 navigation must have exactly 3 tabs.');

  final List<RC5BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(items.length, (index) {
        final isSelected = index == selectedIndex;
        return Flexible(
          flex: isSelected ? 2 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _RC5BottomNavButton(
              item: items[index],
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(index);
              },
            ),
          ),
        );
      }),
    );
  }
}

class _RC5BottomNavButton extends StatelessWidget {
  const _RC5BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final RC5BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      button: true,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedSize(
          duration: RC5DesignTokens.motionBase,
          curve: RC5DesignTokens.easeOut,
          clipBehavior: Clip.none,
          child: AnimatedContainer(
            duration: RC5DesignTokens.motionBase,
            curve: RC5DesignTokens.easeOut,
            height: 52,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 16 : 0,
            ),
            decoration: BoxDecoration(
              color: isSelected ? RC5DesignTokens.ink : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: RC5DesignTokens.ink, width: 2.0),
              boxShadow: RC5DesignTokens.neoShadow(offset: const Offset(3, 3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                item.iconBuilder?.call(
                      isSelected ? Colors.white : RC5DesignTokens.ink,
                      20,
                    ) ??
                    Icon(
                      isSelected ? item.activeIcon ?? item.icon : item.icon,
                      color: isSelected ? Colors.white : RC5DesignTokens.ink,
                      size: 20,
                    ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
