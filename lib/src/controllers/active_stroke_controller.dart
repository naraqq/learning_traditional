import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Holds the points of the stroke currently being drawn.
///
/// Kept deliberately separate from [LessonController] so that pointer-move
/// updates only trigger a cheap `CustomPainter` repaint (via the `repaint:`
/// Listenable hook on [ActiveStrokePainter]) and never a widget rebuild of
/// the rest of the lesson screen.
class ActiveStrokeController extends ChangeNotifier {
  final List<Offset> _livePoints = [];

  /// Normalized 0.0-1.0 pressure per point (0.5 = neutral/unknown, for
  /// devices — most finger touchscreens — that don't report real pressure).
  final List<double> _pressures = [];

  List<Offset> get livePoints => _livePoints;

  /// A subtle brush-width multiplier derived from recent pressure samples.
  /// Devices without real pressure stay at neutral pressure (0.5) so this
  /// evaluates to 1.0 — i.e. no visual change when pressure isn't
  /// available, as required.
  double get widthScale {
    if (_pressures.isEmpty) return 1.0;
    final avg = _pressures.reduce((a, b) => a + b) / _pressures.length;
    return 0.85 + 0.3 * avg;
  }

  void start(Offset point, [double pressure = 0.5]) {
    _livePoints
      ..clear()
      ..add(point);
    _pressures
      ..clear()
      ..add(pressure);
    notifyListeners();
  }

  void addPoint(Offset point, [double pressure = 0.5]) {
    _livePoints.add(point);
    _pressures.add(pressure);
    notifyListeners();
  }

  void clear() {
    if (_livePoints.isEmpty) return;
    _livePoints.clear();
    _pressures.clear();
    notifyListeners();
  }

  List<Offset> takeSnapshot() => List<Offset>.of(_livePoints);
}
