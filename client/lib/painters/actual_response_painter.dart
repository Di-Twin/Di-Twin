import 'package:flutter/material.dart';

// Custom painter for actual response curve
class ActualResponsePainter extends CustomPainter {
  final String curveType;
  final Color color;

  ActualResponsePainter(this.curveType, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    switch (curveType) {
      case 'Low':
        // Gentle curve
        path.quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.45,
          size.width * 0.5,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.55,
          size.width,
          size.height * 0.6,
        );
        break;
      case 'Moderate':
        // Medium curve
        path.quadraticBezierTo(
          size.width * 0.25,
          size.height * 0.3,
          size.width * 0.4,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width * 0.6,
          size.height * 0.3,
          size.width * 0.7,
          size.height * 0.5,
        );
        path.quadraticBezierTo(
          size.width * 0.8,
          size.height * 0.6,
          size.width,
          size.height * 0.6,
        );
        break;
      case 'High':
        // Sharp spike
        path.quadraticBezierTo(
          size.width * 0.2,
          size.height * 0.1,
          size.width * 0.3,
          size.height * 0.1,
        );
        path.quadraticBezierTo(
          size.width * 0.4,
          size.height * 0.1,
          size.width * 0.5,
          size.height * 0.3,
        );
        path.quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.5,
          size.width,
          size.height * 0.6,
        );
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
