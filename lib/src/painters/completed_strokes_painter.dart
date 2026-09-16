import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../geometry/path_builder.dart';
import '../models/completed_stroke.dart';

/// Renders every stroke the learner has already completed. Isolated from
/// the actively-drawing stroke so it is only repainted when the completed
/// list changes or the beautification animation ticks — not on every
/// pointer-move sample.
class CompletedStrokesPainter extends CustomPainter {
  const CompletedStrokesPainter({
    required this.strokes,
    required this.brushWidth,
    required this.glowOpacity,
  });

  final List<CompletedStroke> strokes;
  final double brushWidth;

  /// Applied as a glow behind the most recently completed stroke only,
  /// fading from 1.0 to 0.0 right after acceptance.
  final double glowOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < strokes.length; i++) {
      final stroke = strokes[i];
      final points = SmoothPathBuilder.denormalize(stroke.displayPoints, size);
      final path = SmoothPathBuilder.build(points);
      final inkPaint = Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = brushWidth * size.shortestSide * stroke.widthScale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (i == strokes.length - 1 && glowOpacity > 0) {
        final glowPaint = Paint()
          ..color = AppColors.success.withValues(alpha: 0.55 * glowOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = brushWidth * size.shortestSide * 2.4
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawPath(path, glowPaint);
      }
      canvas.drawPath(path, inkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CompletedStrokesPainter oldDelegate) => true;
}
