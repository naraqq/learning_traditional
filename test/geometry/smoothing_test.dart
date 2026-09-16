import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/geometry/smoothing.dart';

void main() {
  group('StrokeSmoothing.movingAverage', () {
    test('keeps endpoints anchored', () {
      final points = [
        const Offset(0, 0),
        const Offset(1, 5),
        const Offset(2, -5),
        const Offset(3, 5),
        const Offset(4, 0),
      ];
      final result = StrokeSmoothing.movingAverage(points, windowSize: 3);
      expect(result.first, points.first);
      expect(result.last, points.last);
    });

    test('reduces jitter compared to the raw zigzag', () {
      final points = [
        for (var i = 0; i < 20; i++) Offset(i.toDouble(), i.isEven ? 1 : -1),
      ];
      final result = StrokeSmoothing.movingAverage(points, windowSize: 5);

      double variance(List<Offset> pts) {
        final meanY = pts.map((p) => p.dy).reduce((a, b) => a + b) / pts.length;
        final sumSq = pts
            .map((p) => (p.dy - meanY) * (p.dy - meanY))
            .reduce((a, b) => a + b);
        return sumSq / pts.length;
      }

      expect(variance(result), lessThan(variance(points)));
    });

    test('leaves short inputs untouched', () {
      final points = [const Offset(0, 0), const Offset(1, 1)];
      expect(StrokeSmoothing.movingAverage(points), points);
    });
  });

  group('OneEuroLikeFilter', () {
    test('first sample passes through unchanged', () {
      final filter = OneEuroLikeFilter();
      final result = filter.filter(const Offset(5, 5), 0);
      expect(result, const Offset(5, 5));
    });

    test('smooths a jittery sequence toward the underlying trend', () {
      final filter = OneEuroLikeFilter(minCutoff: 0.5, beta: 0.1);
      final raw = <Offset>[];
      final filtered = <Offset>[];
      var t = 0;
      for (var i = 0; i < 30; i++) {
        final trendX = i * 0.02;
        final jitter = i.isEven ? 0.01 : -0.01;
        final point = Offset(trendX + jitter, 0.5);
        raw.add(point);
        filtered.add(filter.filter(point, t));
        t += 16;
      }

      double jitterMagnitude(List<Offset> pts) {
        var total = 0.0;
        for (var i = 1; i < pts.length; i++) {
          total += (pts[i].dx - pts[i - 1].dx).abs();
        }
        return total;
      }

      // The filtered path should not whipsaw back and forth as much as the
      // raw jittery input.
      expect(jitterMagnitude(filtered), lessThan(jitterMagnitude(raw)));
    });

    test(
      'reset clears history so the next sample passes through unchanged',
      () {
        final filter = OneEuroLikeFilter();
        filter.filter(const Offset(0, 0), 0);
        filter.filter(const Offset(1, 1), 16);
        filter.reset();
        final result = filter.filter(const Offset(9, 9), 100);
        expect(result, const Offset(9, 9));
      },
    );
  });
}
