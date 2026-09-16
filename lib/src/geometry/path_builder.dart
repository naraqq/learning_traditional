import 'dart:ui';

/// Builds a smooth-looking [Path] through a polyline using quadratic
/// Bezier segments (control point = raw vertex, end point = the midpoint to
/// the next vertex). This is a cheap, well-known trick to render smooth
/// ink from a point list without fitting a full spline.
class SmoothPathBuilder {
  SmoothPathBuilder._();

  static Path build(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    if (points.length == 1) {
      path.moveTo(points.first.dx, points.first.dy);
      path.lineTo(points.first.dx, points.first.dy);
      return path;
    }
    path.moveTo(points.first.dx, points.first.dy);
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final midpoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      if (i == 0) {
        path.lineTo(midpoint.dx, midpoint.dy);
      } else {
        path.quadraticBezierTo(
          current.dx,
          current.dy,
          midpoint.dx,
          midpoint.dy,
        );
      }
    }
    path.lineTo(points.last.dx, points.last.dy);
    return path;
  }

  /// Converts normalized (0.0-1.0) [points] into pixel space for [size].
  static List<Offset> denormalize(List<Offset> points, Size size) {
    return [
      for (final p in points) Offset(p.dx * size.width, p.dy * size.height),
    ];
  }
}
