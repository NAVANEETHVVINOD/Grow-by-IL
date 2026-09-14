import 'package:flutter/material.dart';
import '../../../core/theme/rc5_design_tokens.dart';

class RC5SearchBar extends StatefulWidget {
  const RC5SearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
    this.onSubmitted,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final ValueChanged<String>? onSubmitted;

  @override
  State<RC5SearchBar> createState() => _RC5SearchBarState();
}

class _RC5SearchBarState extends State<RC5SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant RC5SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: RC5DesignTokens.neoShadow(
          opacity: 0.15,
          offset: const Offset(2, 2),
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: RC5DesignTokens.body.copyWith(
          color: RC5DesignTokens.ink,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: RC5DesignTokens.body.copyWith(
            color: RC5DesignTokens.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: RC5DesignTokens.ink,
            size: 20,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear search',
                icon: const Icon(
                  Icons.clear_rounded,
                  color: RC5DesignTokens.textSecondary,
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
              );
            },
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: RC5DesignTokens.border,
              width: RC5DesignTokens.borderWidth,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: RC5DesignTokens.border,
              width: RC5DesignTokens.borderWidth,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: RC5DesignTokens.ink,
              width: RC5DesignTokens.borderWidth + 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
