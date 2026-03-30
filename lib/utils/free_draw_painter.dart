import 'package:flutter/material.dart';

class FreeDrawPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  FreeDrawPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color.withValues(alpha: .7)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(FreeDrawPainter oldDelegate) => true;
}
