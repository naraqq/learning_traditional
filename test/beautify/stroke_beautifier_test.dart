import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/beautify/stroke_beautifier.dart';

void main() {
  const beautifier = StrokeBeautifier();

  final reference = [for (var i = 0; i <= 10; i++) Offset(0.5, 0.1 + i * 0.08)];

  test('output has the fixed point count and stays within the unit square', () {
    final shaky = [
      for (var i = 0; i <= 10; i++)
        Offset(0.5 + (i.isEven ? 0.05 : -0.05), 0.1 + i * 0.08),
    ];
    final result = beautifier.beautify(
      userPoints: shaky,
      referencePoints: reference,
      similarityScore: 65,
    );
    expect(result.length, StrokeBeautifier.pointCount);
    for (final p in result) {
      expect(p.dx, inInclusiveRange(0.0, 1.0));
      expect(p.dy, inInclusiveRange(0.0, 1.0));
    }
  });

  test('clamps even when raw input strays outside the unit square', () {
    final offCanvas = [
      const Offset(-0.2, -0.1),
      const Offset(0.5, 0.5),
      const Offset(1.3, 1.2),
    ];
    final result = beautifier.beautify(
      userPoints: offCanvas,
      referencePoints: reference,
      similarityScore: 80,
    );
    for (final p in result) {
      expect(p.dx, inInclusiveRange(0.0, 1.0));
      expect(p.dy, inInclusiveRange(0.0, 1.0));
    }
  });

  test('blend factor is monotonically lighter as similarity increases', () {
    final low = beautifier.blendFactorFor(20);
    final mid = beautifier.blendFactorFor(60);
    final high = beautifier.blendFactorFor(95);
    expect(low, greaterThan(mid));
    expect(mid, greaterThan(high));
    // Even the lightest correction still pulls firmly toward the reference
    // so accepted strokes read as the clean letterform, not raw input.
    expect(high, greaterThanOrEqualTo(0.70));
    expect(low, lessThanOrEqualTo(0.97));
  });

  test('even high-quality input keeps a trace of personal variation', () {
    final closeToReference = [
      for (var i = 0; i <= 10; i++) Offset(0.5 + 0.005, 0.1 + i * 0.08),
    ];
    final result = beautifier.beautify(
      userPoints: closeToReference,
      referencePoints: reference,
      similarityScore: 98,
    );
    // The result should converge heavily toward the reference centerline
    // (x = 0.5) but never snap to it exactly.
    final anyPointRetainsOffset = result.any(
      (p) => (p.dx - 0.5).abs() > 0.0005,
    );
    expect(anyPointRetainsOffset, isTrue);
    for (final p in result) {
      expect((p.dx - 0.5).abs(), lessThan(0.005));
    }
  });
}
