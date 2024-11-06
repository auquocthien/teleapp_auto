import 'package:flutter/material.dart';

class EventLinePainter extends CustomPainter {
  final List<Offset> points;

  EventLinePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length > 1) {
      final paint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      // Vẽ đường qua tất cả các điểm
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
