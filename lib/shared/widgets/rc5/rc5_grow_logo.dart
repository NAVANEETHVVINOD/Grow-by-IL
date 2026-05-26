import 'package:flutter/material.dart';

class RC5GrowLogo extends StatelessWidget {
  const RC5GrowLogo({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF5D7), // Pastel green background
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF111111), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF111111),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _GrowLogoPainter(),
        ),
      ),
    );
  }
}

class _GrowLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFF111111)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round;

    // Draw stalk (curving up and right)
    final stalkPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.9)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.25,
      );
    canvas.drawPath(stalkPath, strokePaint);

    // Draw arrowhead at the tip
    final arrowPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.25)
      ..lineTo(size.width * 0.9, size.height * 0.1)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..close();
    canvas.drawPath(arrowPath, paint);

    // Draw leaf on the left
    final leafPath = Path()
      ..moveTo(size.width * 0.3, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.02,
        size.height * 0.5,
        size.width * 0.05,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.45,
        size.width * 0.3,
        size.height * 0.65,
      );
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
