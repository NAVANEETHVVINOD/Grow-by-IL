import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

class RC5Card extends StatefulWidget {
  const RC5Card({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(RC5DesignTokens.space4),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = RC5DesignTokens.surface,
    this.gradient,
    this.borderColor = RC5DesignTokens.ink,
    this.radius = RC5DesignTokens.radiusMd,
    this.shadowOpacity = 1,
    this.enablePressEffect = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color borderColor;
  final double radius;
  final double shadowOpacity;
  final bool enablePressEffect;

  @override
  State<RC5Card> createState() => _RC5CardState();
}

class _RC5CardState extends State<RC5Card> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!widget.enablePressEffect || widget.onTap == null) return;
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final content = AnimatedScale(
      duration: RC5DesignTokens.motionFast,
      curve: RC5DesignTokens.easeOut,
      scale: _isPressed ? 0.985 : 1,
      child: AnimatedContainer(
        duration: RC5DesignTokens.motionBase,
        curve: RC5DesignTokens.easeOut,
        margin: widget.margin,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.gradient == null ? widget.backgroundColor : null,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: widget.borderColor,
            width: RC5DesignTokens.borderWidth,
          ),
          boxShadow: _isPressed
              ? []
              : RC5DesignTokens.neoShadow(opacity: widget.shadowOpacity),
        ),
        child: widget.child,
      ),
    );

    if (widget.onTap == null) return content;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        child: content,
      ),
    );
  }
}
