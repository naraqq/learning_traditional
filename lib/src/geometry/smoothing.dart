import 'dart:ui';

/// Lightweight smoothing utilities for handwriting input. Kept intentionally
/// simple (no external packages) but effective enough to take the shake out
/// of natural finger/stylus input.
class StrokeSmoothing {
  StrokeSmoothing._();

  /// Applies a centered moving-average filter. Endpoints are kept anchored
  /// to the original data so a smoothed stroke doesn't visually shrink away
  /// from where the learner actually started/finished.
  static List<Offset> movingAverage(List<Offset> points, {int windowSize = 3}) {
    if (points.length < 3 || windowSize < 2) return List<Offset>.of(points);
    final radius = windowSize ~/ 2;
    final result = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      if (i == 0 || i == points.length - 1) {
        result.add(points[i]);
        continue;
      }
      final lo = (i - radius).clamp(0, points.length - 1);
      final hi = (i + radius).clamp(0, points.length - 1);
      var sx = 0.0;
      var sy = 0.0;
      var n = 0;
      for (var j = lo; j <= hi; j++) {
        sx += points[j].dx;
        sy += points[j].dy;
        n++;
      }
      result.add(Offset(sx / n, sy / n));
    }
    return result;
  }

  /// Same idea as [movingAverage] but for a closed loop (e.g. a traced
  /// glyph outline): every point is averaged with its cyclic neighbors, so
  /// there are no anchored "ends" to seam at and small photographic
  /// tracing noise gets smoothed out evenly all the way around.
  static List<Offset> closedMovingAverage(
    List<Offset> points, {
    int windowSize = 3,
  }) {
    if (points.length < 3 || windowSize < 2) return List<Offset>.of(points);
    final radius = windowSize ~/ 2;
    final n = points.length;
    final result = <Offset>[];
    for (var i = 0; i < n; i++) {
      var sx = 0.0;
      var sy = 0.0;
      for (var j = -radius; j <= radius; j++) {
        final p = points[(i + j + n) % n];
        sx += p.dx;
        sy += p.dy;
      }
      final count = radius * 2 + 1;
      result.add(Offset(sx / count, sy / count));
    }
    return result;
  }
}

/// A minimal One-Euro-Filter-style low-pass filter for real-time point
/// smoothing while the user is actively drawing. It follows the same core
/// idea as the One Euro Filter (Casiez et al.): more smoothing at low
/// speed to kill jitter, less smoothing at high speed so fast strokes
/// don't visibly lag behind the finger.
class OneEuroLikeFilter {
  OneEuroLikeFilter({this.minCutoff = 1.0, this.beta = 0.3});

  /// Base cutoff frequency; higher values track the raw signal more
  /// closely (less smoothing) even at low speed.
  final double minCutoff;

  /// How much the cutoff frequency increases with speed. Higher values
  /// make fast movements even less smoothed.
  final double beta;

  Offset? _lastFiltered;
  Offset? _lastRaw;
  int? _lastTimestampMs;

  /// Filters [point] captured at [timestampMs]. The first call in a stroke
  /// always returns the raw point unchanged (nothing to smooth against
  /// yet); call [reset] between strokes.
  Offset filter(Offset point, int timestampMs) {
    if (_lastFiltered == null || _lastTimestampMs == null) {
      _lastFiltered = point;
      _lastRaw = point;
      _lastTimestampMs = timestampMs;
      return point;
    }

    final dtMs = (timestampMs - _lastTimestampMs!).abs();
    final dt = (dtMs / 1000.0).clamp(0.001, 1.0);
    final speed = (point - _lastRaw!).distance / dt;
    final cutoff = minCutoff + beta * speed;
    final alpha = _smoothingFactor(dt, cutoff);

    final smoothed = Offset(
      _lastFiltered!.dx + alpha * (point.dx - _lastFiltered!.dx),
      _lastFiltered!.dy + alpha * (point.dy - _lastFiltered!.dy),
    );

    _lastFiltered = smoothed;
    _lastRaw = point;
    _lastTimestampMs = timestampMs;
    return smoothed;
  }

  double _smoothingFactor(double dt, double cutoff) {
    final r = 2 * 3.14159265358979 * cutoff * dt;
    return r / (r + 1);
  }

  void reset() {
    _lastFiltered = null;
    _lastRaw = null;
    _lastTimestampMs = null;
  }
}
