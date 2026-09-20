import 'package:flutter/material.dart';

class TalonLogo extends StatelessWidget {
  const TalonLogo({
    super.key,
    this.size = 120,
    this.color = Colors.black,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TalonLogoPainter(color),
    );
  }
}

class _TalonLogoPainter extends CustomPainter {
  final Color color;

  _TalonLogoPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width * 0.5, 0);

    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.2,
      size.width * 0.7,
      size.height * 0.5,
    );

    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.3,
      size.height,
    );

    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.2,
      size.height * 0.3,
    );

    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.15,
      size.width * 0.5,
      0,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}