import 'package:flutter/material.dart';
import 'package:grow/core/theme/rc5_design_tokens.dart';
import 'package:shimmer/shimmer.dart';

class RC5Skeleton extends StatelessWidget {
  const RC5Skeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = RC5DesignTokens.radiusMd,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: RC5DesignTokens.surfaceAlt,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: RC5DesignTokens.surfaceAlt,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class RC5SkeletonList extends StatelessWidget {
  const RC5SkeletonList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 84,
    this.spacing = RC5DesignTokens.space3,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : spacing),
          child: RC5Skeleton(
            width: double.infinity,
            height: itemHeight,
          ),
        );
      }),
    );
  }
}
