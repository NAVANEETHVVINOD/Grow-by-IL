import 'package:flutter/material.dart';

class RC5KeralaMarkIcon extends StatelessWidget {
  const RC5KeralaMarkIcon({
    super.key,
    required this.color,
    this.size = 22,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _KeralaMarkPainter(color: color),
      ),
    );
  }
}

class _KeralaMarkPainter extends CustomPainter {
  const _KeralaMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final coast = Path()
      ..moveTo(size.width * 0.55, size.height * 0.08)
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.20,
        size.width * 0.32,
        size.height * 0.36,
        size.width * 0.46,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.64,
        size.width * 0.40,
        size.height * 0.78,
        size.width * 0.55,
        size.height * 0.93,
      );

    final backwater = Path()
      ..moveTo(size.width * 0.72, size.height * 0.18)
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.34,
        size.width * 0.76,
        size.height * 0.50,
        size.width * 0.62,
        size.height * 0.58,
      );

    canvas.drawPath(coast, stroke);
    canvas.drawPath(backwater, stroke);
    canvas.drawCircle(
      Offset(size.width * 0.37, size.height * 0.32),
      size.width * 0.07,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _KeralaMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
