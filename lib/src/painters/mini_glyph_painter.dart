import 'package:flutter/material.dart';

import '../geometry/path_builder.dart';
import '../geometry/smoothing.dart';
import '../models/character_definition.dart';

/// Tiny preview of a character's full glyph (all strokes), used inside
/// path nodes on the home screen. Static — no zones, no badges, just ink.
class MiniGlyphPainter extends CustomPainter {
  const MiniGlyphPainter({required this.character, required this.color});

  final CharacterDefinition character;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (character.outlineContours.isNotEmpty) {
      final side = size.shortestSide;
      canvas.save();
      canvas.translate((size.width - side) / 2, (size.height - side) / 2);
      canvas.drawPath(
        chartOutlinePath(character, Size.square(side)),
        Paint()..color = color,
      );
      canvas.restore();
      return;
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final stroke in character.strokes) {
      final points = SmoothPathBuilder.denormalize(stroke.points, size);
      canvas.drawPath(SmoothPathBuilder.build(points), paint);
    }
  }

  @override
  bool shouldRepaint(covariant MiniGlyphPainter oldDelegate) {
    return oldDelegate.character != character || oldDelegate.color != color;
  }
}

/// Shared by letter previews and the handwriting guide.
Path chartOutlinePath(CharacterDefinition character, Size size) {
  final path = Path()..fillType = PathFillType.evenOdd;
  for (final contour in character.outlineContours) {
    if (contour.length < 3) continue;
    // A light circular pass takes out the small per-vertex noise left by
    // photographic tracing before the curve is built through every point,
    // without rounding away the shape's real corners and thin spurs.
    final points = StrokeSmoothing.closedMovingAverage(
      SmoothPathBuilder.denormalize(contour, size),
    );
    // Closed midpoint quadratics have continuous tangents at every join.
    // Their convex hull stays inside the cleaned contour, unlike an
    // interpolating spline that can overshoot narrow loops and dot marks.
    final start = (points.last + points.first) / 2;
    path.moveTo(start.dx, start.dy);
    for (var i = 0; i < points.length; i++) {
      final control = points[i];
      final end = (control + points[(i + 1) % points.length]) / 2;
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }
    path.close();
  }
  return path;
}
