import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';

enum RC5ButtonVariant { primary, secondary, ghost, destructive }

class RC5Button extends StatefulWidget {
  const RC5Button({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = RC5ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final RC5ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final double height;

  @override
  State<RC5Button> createState() => _RC5ButtonState();
}

class _RC5ButtonState extends State<RC5Button> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  void _setPressed(bool value) {
    if (!_isEnabled || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _RC5ButtonPalette.forVariant(widget.variant);

    return AnimatedScale(
      duration: RC5DesignTokens.motionFast,
      curve: RC5DesignTokens.easeOut,
      scale: _isPressed ? 0.97 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: _isEnabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: RC5DesignTokens.motionBase,
          curve: RC5DesignTokens.easeOut,
          width: widget.fullWidth ? double.infinity : null,
          height: widget.height,
          padding: const EdgeInsets.symmetric(
            horizontal: RC5DesignTokens.space4,
          ),
          decoration: BoxDecoration(
            color: _isEnabled ? palette.background : RC5DesignTokens.surfaceAlt,
            borderRadius: BorderRadius.circular(RC5DesignTokens.radiusMd),
            border: Border.all(
              color: _isEnabled ? palette.border : RC5DesignTokens.border,
              width: RC5DesignTokens.borderWidth,
            ),
            boxShadow: _isPressed ||
                    !_isEnabled ||
                    widget.variant == RC5ButtonVariant.ghost
                ? []
                : RC5DesignTokens.neoShadow(opacity: 0.95),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: RC5DesignTokens.motionBase,
              child: widget.isLoading
                  ? SizedBox(
                      key: const ValueKey('loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.foreground,
                        ),
                      ),
                    )
                  : Row(
                      key: const ValueKey('content'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 19,
                            color: _isEnabled
                                ? palette.foreground
                                : RC5DesignTokens.muted,
                          ),
                          const SizedBox(width: RC5DesignTokens.space2),
                        ],
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: _isEnabled
                                      ? palette.foreground
                                      : RC5DesignTokens.muted,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RC5ButtonPalette {
  const _RC5ButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  static _RC5ButtonPalette forVariant(RC5ButtonVariant variant) {
    return switch (variant) {
      RC5ButtonVariant.primary => const _RC5ButtonPalette(
          background: RC5DesignTokens.ink,
          foreground: Colors.white,
          border: RC5DesignTokens.ink,
        ),
      RC5ButtonVariant.secondary => const _RC5ButtonPalette(
          background: Colors.white,
          foreground: RC5DesignTokens.ink,
          border: RC5DesignTokens.ink,
        ),
      RC5ButtonVariant.ghost => const _RC5ButtonPalette(
          background: Colors.transparent,
          foreground: RC5DesignTokens.ink,
          border: RC5DesignTokens.border,
        ),
      RC5ButtonVariant.destructive => const _RC5ButtonPalette(
          background: RC5DesignTokens.error,
          foreground: Colors.white,
          border: RC5DesignTokens.ink,
        ),
    };
  }
}
