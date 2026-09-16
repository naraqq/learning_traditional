import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import '../geometry/path_builder.dart';
import '../models/character_definition.dart';

/// Draws the faint reference strokes for the whole character, stroke-order
/// number badges, and the start/end zone hints for the currently expected
/// stroke. Repaints only when the character or the expected stroke index
/// changes — never on pointer movement.
class ReferenceGuidePainter extends CustomPainter {
  const ReferenceGuidePainter({
    required this.character,
    required this.currentStrokeIndex,
  });

  final CharacterDefinition character;
  final int currentStrokeIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final faintPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = character.recommendedBrushWidth * size.shortestSide
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in character.strokes) {
      final points = SmoothPathBuilder.denormalize(stroke.points, size);
      canvas.drawPath(SmoothPathBuilder.build(points), faintPaint);
      final isActive = stroke.order - 1 == currentStrokeIndex;
      _drawOrderBadge(canvas, stroke.order, points.first, isActive);
    }

    if (currentStrokeIndex < character.strokes.length) {
      final active = character.strokes[currentStrokeIndex];
      final startPx = Offset(
        active.start.dx * size.width,
        active.start.dy * size.height,
      );
      final endPx = Offset(
        active.end.dx * size.width,
        active.end.dy * size.height,
      );
      final startRadius =
          (active.startZoneRadius ?? character.startZoneRadius) *
          size.shortestSide;
      final endRadius =
          (active.endZoneRadius ?? character.endZoneRadius) * size.shortestSide;

      canvas.drawCircle(
        startPx,
        startRadius,
        Paint()..color = AppColors.primary.withValues(alpha: 0.16),
      );
      canvas.drawCircle(
        startPx,
        startRadius,
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.drawCircle(
        endPx,
        endRadius,
        Paint()..color = AppColors.secondary.withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        endPx,
        endRadius,
        Paint()
          ..color = AppColors.secondary.withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawOrderBadge(
    Canvas canvas,
    int order,
    Offset strokeStartPx,
    bool isActive,
  ) {
    final center = strokeStartPx.translate(-14, -14);
    canvas.drawCircle(
      center,
      9,
      Paint()..color = isActive ? AppColors.primary : Colors.black26,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$order',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant ReferenceGuidePainter oldDelegate) {
    return oldDelegate.character != character ||
        oldDelegate.currentStrokeIndex != currentStrokeIndex;
  }
}
