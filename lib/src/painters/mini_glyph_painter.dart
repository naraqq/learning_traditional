import 'package:flutter/material.dart';

import '../geometry/path_builder.dart';
import '../models/character_definition.dart';

/// Tiny preview of a character's full glyph (all strokes), used inside
/// path nodes on the home screen. Static — no zones, no badges, just ink.
class MiniGlyphPainter extends CustomPainter {
  const MiniGlyphPainter({required this.character, required this.color});

  final CharacterDefinition character;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
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
