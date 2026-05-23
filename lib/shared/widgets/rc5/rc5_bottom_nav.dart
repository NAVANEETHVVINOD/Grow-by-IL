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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: RC5DesignTokens.background,
        border: Border(
          top: BorderSide(
            color: RC5DesignTokens.border,
            width: RC5DesignTokens.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: RC5DesignTokens.space4,
            vertical: RC5DesignTokens.space2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              return Expanded(
                child: Center(
                  child: _RC5BottomNavButton(
                    item: items[index],
                    isSelected: index == selectedIndex,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(index);
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ),
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
        child: AnimatedContainer(
          duration: RC5DesignTokens.motionBase,
          curve: RC5DesignTokens.easeOut,
          height: 44,
          constraints: BoxConstraints(
            minWidth: isSelected ? 104 : 44,
            maxWidth: isSelected ? 138 : 52,
          ),
          padding: EdgeInsets.symmetric(
            horizontal:
                isSelected ? RC5DesignTokens.space4 : RC5DesignTokens.space3,
          ),
          decoration: BoxDecoration(
            color: isSelected ? RC5DesignTokens.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(RC5DesignTokens.radiusPill),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              item.iconBuilder?.call(
                    isSelected ? Colors.white : RC5DesignTokens.muted,
                    22,
                  ) ??
                  Icon(
                    isSelected ? item.activeIcon ?? item.icon : item.icon,
                    color: isSelected ? Colors.white : RC5DesignTokens.muted,
                    size: 22,
                  ),
              ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.centerLeft,
                  duration: RC5DesignTokens.motionBase,
                  curve: RC5DesignTokens.easeOut,
                  widthFactor: isSelected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: RC5DesignTokens.space2,
                    ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
