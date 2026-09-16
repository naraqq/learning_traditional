import 'package:flutter/material.dart';

import '../models/character_definition.dart';
import '../theme/app_theme.dart';

/// Paints the practice "paper" behind the writing area: a warm off-white
/// base, a faint dot grid, dashed margin guides either side of the column,
/// a center spine guide — the kind of ruled, decorated sheet a printed handwriting
/// workbook would use, rather than a blank white rectangle.
class WritingSheetPainter extends CustomPainter {
  const WritingSheetPainter({required this.character});

  final CharacterDefinition character;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFFDF7),
    );

    _drawDotGrid(canvas, size);
    _drawGuideLines(canvas, size);
  }

  void _drawDotGrid(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppColors.ink.withValues(alpha: 0.035);
    const spacing = 24.0;
    for (var y = spacing; y < size.height; y += spacing) {
      for (var x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 1.1, dotPaint);
      }
    }
  }

  void _drawGuideLines(Canvas canvas, Size size) {
    // Kept deliberately faint — these are a background ruling, not
    // something that should visually compete with the reference stroke or
    // the learner's ink.
    final marginPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.055)
      ..strokeWidth = 1.2;
    _dashedVertical(
      canvas,
      size,
      size.width * 0.18,
      marginPaint,
      dash: 4,
      gap: 7,
    );
    _dashedVertical(
      canvas,
      size,
      size.width * 0.82,
      marginPaint,
      dash: 4,
      gap: 7,
    );

    final centerPaint = Paint()
      ..color = AppColors.ink.withValues(alpha: 0.08)
      ..strokeWidth = 1.2;
    _dashedVertical(
      canvas,
      size,
      size.width * 0.5,
      centerPaint,
      dash: 5,
      gap: 6,
    );
  }

  void _dashedVertical(
    Canvas canvas,
    Size size,
    double x,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, (y + dash).clamp(0, size.height)),
        paint,
      );
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant WritingSheetPainter oldDelegate) =>
      oldDelegate.character != character;
}
