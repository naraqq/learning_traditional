import 'package:flutter/material.dart';

import '../controllers/active_stroke_controller.dart';
import '../geometry/path_builder.dart';

/// Draws the stroke currently being drawn by the learner. Hooked to
/// [ActiveStrokeController] via the `repaint:` Listenable so every pointer
/// sample triggers a cheap, isolated repaint of just this layer — no
/// widget rebuild anywhere on the screen.
class ActiveStrokePainter extends CustomPainter {
  ActiveStrokePainter(this.controller, {required this.brushWidth})
    : super(repaint: controller);

  final ActiveStrokeController controller;
  final double brushWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final points = controller.livePoints;
    if (points.length < 2) return;
    final px = SmoothPathBuilder.denormalize(points, size);
    final path = SmoothPathBuilder.build(px);
    final paint = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = brushWidth * size.shortestSide * controller.widthScale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ActiveStrokePainter oldDelegate) => true;
}
