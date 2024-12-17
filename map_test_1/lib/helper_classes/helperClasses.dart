import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<Offset> points; // Points to draw the line
  final int maxTickCount; // Maximum number of tick marks to show

  LinePainter(this.points, {this.maxTickCount = 20});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the line
    final linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // Paint for tick marks
    final tickPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0;

    // Draw the line
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    // Determine tick intervals if points exceed maxTickCount
    int interval = 1;
    if (points.length > maxTickCount) {
      interval = (points.length / maxTickCount).ceil();
    }

    // Draw tick marks at regular intervals
    for (int i = 0; i < points.length; i += interval) {
      Offset point = points[i];
      const double tickLength = 8.0;

      // Draw small ticks perpendicular to the line (up and down)
      canvas.drawLine(
        Offset(point.dx, point.dy - tickLength),
        Offset(point.dx, point.dy + tickLength),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Update if points or settings change
  }
}
