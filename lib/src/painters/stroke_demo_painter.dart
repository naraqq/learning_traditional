import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../geometry/geometry_utils.dart';
import '../geometry/path_builder.dart';
import '../models/reference_stroke.dart';

/// Draws the animated stroke-order demonstration: the reference stroke
/// revealed up to [progress] (0..1), with a leading dot showing the pen
/// tip's current position and direction of travel.
class StrokeDemoPainter extends CustomPainter {
  const StrokeDemoPainter({required this.stroke, required this.progress});

  final ReferenceStroke? stroke;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final s = stroke;
    if (s == null || progress <= 0) return;
    final full = SmoothPathBuilder.denormalize(s.points, size);
    final sampleCount = (full.length * 6).clamp(8, 200);
    final resampled = GeometryUtils.resample(full, sampleCount);
    final upto = (resampled.length * progress)
        .clamp(1, resampled.length)
        .round();
    final visible = resampled.sublist(0, upto);
    if (visible.length < 2) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(SmoothPathBuilder.build(visible), paint);
    canvas.drawCircle(visible.last, 6, Paint()..color = AppColors.secondary);
  }

  @override
  bool shouldRepaint(covariant StrokeDemoPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.stroke != stroke;
  }
}
