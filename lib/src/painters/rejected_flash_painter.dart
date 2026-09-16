import 'package:flutter/material.dart';

import '../geometry/path_builder.dart';

/// Briefly renders a rejected stroke in red so the learner sees what went
/// wrong before it fades away.
class RejectedFlashPainter extends CustomPainter {
  const RejectedFlashPainter({
    required this.points,
    required this.opacity,
    required this.brushWidth,
  });

  final List<Offset>? points;
  final double opacity;
  final double brushWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final pts = points;
    if (pts == null || pts.length < 2 || opacity <= 0) return;
    final px = SmoothPathBuilder.denormalize(pts, size);
    final paint = Paint()
      ..color = Colors.redAccent.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = brushWidth * size.shortestSide
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(SmoothPathBuilder.build(px), paint);
  }

  @override
  bool shouldRepaint(covariant RejectedFlashPainter oldDelegate) => true;
}
