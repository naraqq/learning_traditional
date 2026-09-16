import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/geometry/geometry_utils.dart';

void main() {
  group('GeometryUtils.resample', () {
    test('preserves endpoints and produces the requested count', () {
      final points = [
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(1, 1),
      ];
      final result = GeometryUtils.resample(points, 10);
      expect(result.length, 10);
      expect(result.first, const Offset(0, 0));
      expect(result.last, const Offset(1, 1));
    });

    test('spaces points evenly along a straight line', () {
      final points = [const Offset(0, 0), const Offset(10, 0)];
      final result = GeometryUtils.resample(points, 5);
      expect(result.length, 5);
      for (var i = 0; i < result.length; i++) {
        expect(result[i].dx, closeTo(i * 2.5, 1e-9));
        expect(result[i].dy, closeTo(0, 1e-9));
      }
    });

    test('handles duplicate consecutive points without dividing by zero', () {
      final points = [
        const Offset(0, 0),
        const Offset(0, 0),
        const Offset(2, 0),
        const Offset(2, 0),
        const Offset(2, 2),
      ];
      final result = GeometryUtils.resample(points, 4);
      expect(result.length, 4);
      expect(result.first, const Offset(0, 0));
      expect(result.last, const Offset(2, 2));
    });

    test('degenerate single-point input returns that point repeated', () {
      final result = GeometryUtils.resample([const Offset(3, 4)], 6);
      expect(result, List.filled(6, const Offset(3, 4)));
    });

    test('throws for count below 2', () {
      expect(
        () => GeometryUtils.resample([const Offset(0, 0)], 1),
        throwsArgumentError,
      );
    });
  });

  group('GeometryUtils.pathLength', () {
    test('sums straight segment lengths', () {
      final points = [
        const Offset(0, 0),
        const Offset(3, 0),
        const Offset(3, 4),
      ];
      expect(GeometryUtils.pathLength(points), closeTo(7, 1e-9));
    });
  });

  group('GeometryUtils.coverageFraction', () {
    test('is 1.0 when every reference point has a close candidate', () {
      final ref = [const Offset(0, 0), const Offset(1, 0), const Offset(2, 0)];
      final candidate = [
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(2, 0),
      ];
      expect(GeometryUtils.coverageFraction(ref, candidate, 0.01), 1.0);
    });

    test('drops when the candidate only covers part of the reference', () {
      final ref = [
        const Offset(0, 0),
        const Offset(1, 0),
        const Offset(2, 0),
        const Offset(3, 0),
      ];
      final candidate = [const Offset(0, 0), const Offset(1, 0)];
      final coverage = GeometryUtils.coverageFraction(ref, candidate, 0.2);
      expect(coverage, closeTo(0.5, 1e-9));
    });
  });
}
