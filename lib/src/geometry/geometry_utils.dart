import 'dart:ui';

/// Pure geometry helpers shared by capture, validation and beautification.
/// Deliberately free of Flutter widget dependencies so they can be unit
/// tested in isolation from the UI.
class GeometryUtils {
  GeometryUtils._();

  static double distance(Offset a, Offset b) => (a - b).distance;

  /// Total polyline length through [points].
  static double pathLength(List<Offset> points) {
    if (points.length < 2) return 0;
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += distance(points[i - 1], points[i]);
    }
    return total;
  }

  /// Removes consecutive duplicate/near-duplicate points so arc-length math
  /// never divides by a zero-length segment.
  static List<Offset> dedupe(List<Offset> points, {double epsilon = 1e-9}) {
    final result = <Offset>[];
    for (final p in points) {
      if (result.isEmpty || distance(result.last, p) > epsilon) {
        result.add(p);
      }
    }
    return result;
  }

  /// Resamples [points] into exactly [count] points spaced evenly along the
  /// polyline's arc length. The first and last output points always match
  /// the first and last input points.
  ///
  /// Degenerate input (fewer than 2 distinct points) returns [count] copies
  /// of the single available point (or [Offset.zero] if there is none), so
  /// callers can rely on a fixed-length result without extra branching.
  static List<Offset> resample(List<Offset> points, int count) {
    if (count < 2) {
      throw ArgumentError.value(count, 'count', 'must be >= 2');
    }
    final cleaned = dedupe(points);
    if (cleaned.isEmpty) {
      return List<Offset>.filled(count, Offset.zero);
    }
    if (cleaned.length < 2) {
      return List<Offset>.filled(count, cleaned.first);
    }

    final total = pathLength(cleaned);
    if (total <= 0) {
      return List<Offset>.filled(count, cleaned.first);
    }

    final step = total / (count - 1);
    final result = <Offset>[cleaned.first];

    var segmentIndex = 0;
    var accumulated = 0.0;
    for (var i = 1; i < count - 1; i++) {
      final targetDist = step * i;
      while (segmentIndex < cleaned.length - 2 &&
          accumulated +
                  distance(cleaned[segmentIndex], cleaned[segmentIndex + 1]) <
              targetDist) {
        accumulated += distance(
          cleaned[segmentIndex],
          cleaned[segmentIndex + 1],
        );
        segmentIndex++;
      }
      final segStart = cleaned[segmentIndex];
      final segEnd = cleaned[segmentIndex + 1];
      final segLen = distance(segStart, segEnd);
      final t = segLen == 0
          ? 0.0
          : ((targetDist - accumulated) / segLen).clamp(0.0, 1.0);
      result.add(Offset.lerp(segStart, segEnd, t)!);
    }
    result.add(cleaned.last);
    return result;
  }

  /// Average pairwise distance between two equal-length, index-aligned
  /// point lists (i.e. the mean per-point deviation between two already
  /// resampled strokes).
  static double averagePointDistance(List<Offset> a, List<Offset> b) {
    assert(a.length == b.length);
    if (a.isEmpty) return 0;
    var total = 0.0;
    for (var i = 0; i < a.length; i++) {
      total += distance(a[i], b[i]);
    }
    return total / a.length;
  }

  /// True when [a] and [b] are at least [minDistance] apart. Used to skip
  /// pointer samples that are too close together to add useful detail.
  static bool isFarEnough(Offset a, Offset b, double minDistance) =>
      distance(a, b) >= minDistance;

  /// Clamps a point into the normalized unit square.
  static Offset clampUnit(Offset point) {
    return Offset(point.dx.clamp(0.0, 1.0), point.dy.clamp(0.0, 1.0));
  }

  /// Fraction (0.0-1.0) of [reference] points that have some [candidate]
  /// point within [tolerance] of them. Used to measure how much of the
  /// reference stroke the learner actually traced.
  static double coverageFraction(
    List<Offset> reference,
    List<Offset> candidate,
    double tolerance,
  ) {
    if (reference.isEmpty) return 1;
    if (candidate.isEmpty) return 0;
    var covered = 0;
    for (final refPoint in reference) {
      var nearest = double.infinity;
      for (final candidatePoint in candidate) {
        final d = distance(refPoint, candidatePoint);
        if (d < nearest) nearest = d;
        if (nearest <= tolerance) break;
      }
      if (nearest <= tolerance) covered++;
    }
    return covered / reference.length;
  }
}
