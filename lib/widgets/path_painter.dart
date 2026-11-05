import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TrackPathPainter extends CustomPainter {
  final List<Offset> points;
  final int completedCount;

  TrackPathPainter({
    required this.points,
    required this.completedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final basePaint = Paint()
      ..color = AppTheme.surfaceElevated.withValues(alpha: 0.6)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final completedPaint = Paint()
      ..color = AppTheme.neonGreen.withValues(alpha: 0.8)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      final path = Path();
      path.moveTo(p1.dx, p1.dy);

      final controlPoint1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) / 2);
      final controlPoint2 = Offset(p2.dx, p1.dy + (p2.dy - p1.dy) / 2);

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );

      final isSegmentCompleted = i < completedCount;
      canvas.drawPath(path, isSegmentCompleted ? completedPaint : basePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrackPathPainter oldDelegate) {
    return oldDelegate.completedCount != completedCount ||
        oldDelegate.points != points;
  }
}
