import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../geometry/path_builder.dart';

/// Decorative "world map" scenery behind the letter path: a sky-to-steppe
/// gradient, a couple of drifting clouds, and a winding dirt road
/// connecting each node with a soft ground shadow beneath it — the game
/// lesson-map look, themed around the Mongolian steppe instead of a plain
/// dashed line.
class PathScenePainter extends CustomPainter {
  const PathScenePainter({
    required this.nodeCount,
    required this.nodeHeight,
    required this.alignmentXs,
  });

  final int nodeCount;
  final double nodeHeight;

  /// The horizontal alignment (-1..1) each node cycles through, matching
  /// the `Align` widgets the nodes themselves are laid out with — kept in
  /// sync so the painted road passes exactly through each node's center.
  final List<double> alignmentXs;

  static const double _nodeDiameter = 104;

  Offset _nodeCenter(int index, double width) {
    final ax = alignmentXs[index % alignmentXs.length];
    final left = (width - _nodeDiameter) / 2 * (1 + ax);
    return Offset(
      left + _nodeDiameter / 2,
      index * nodeHeight + nodeHeight / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    final centers = [
      for (var i = 0; i < nodeCount; i++) _nodeCenter(i, size.width),
    ];
    _paintClouds(canvas, size);
    _paintRoad(canvas, centers);
    _paintGroundShadows(canvas, centers);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE6EFFE), Color(0xFFEAF6E6)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final rows = (size.height / nodeHeight).ceil();
    for (var i = 0; i < rows; i += 2) {
      final cx = (i % 4 == 0 ? 0.22 : 0.78) * size.width;
      final cy = i * nodeHeight + nodeHeight * 0.16;
      _drawCloud(canvas, Offset(cx, cy), 24, paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double r, Paint paint) {
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(r * 0.95, r * 0.18), r * 0.72, paint);
    canvas.drawCircle(center.translate(-r * 0.95, r * 0.22), r * 0.6, paint);
  }

  void _paintRoad(Canvas canvas, List<Offset> centers) {
    if (centers.length < 2) return;
    final road = SmoothPathBuilder.build(centers);

    // A slightly wider "edge" stroke drawn first, then a narrower "base"
    // stroke on top, gives the road a bordered/paved look rather than a
    // single flat line.
    final edgePaint = Paint()
      ..color = const Color(0xFFC9B685)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(road, edgePaint);

    final basePaint = Paint()
      ..color = const Color(0xFFE0D2A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(road, basePaint);

    final centerlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_dashedPath(road, dash: 12, gap: 10), centerlinePaint);
  }

  Path _dashedPath(Path source, {required double dash, required double gap}) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        dashed.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + gap;
      }
    }
    return dashed;
  }

  void _paintGroundShadows(Canvas canvas, List<Offset> centers) {
    // Sits just under the 84-diameter node circle (radius 42) so it grounds
    // the node without reaching down into its label text below.
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.09);
    for (final center in centers) {
      canvas.save();
      canvas.translate(center.dx, center.dy + 40);
      canvas.scale(1, 0.26);
      canvas.drawCircle(Offset.zero, 36, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PathScenePainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount ||
        oldDelegate.nodeHeight != nodeHeight;
  }
}
