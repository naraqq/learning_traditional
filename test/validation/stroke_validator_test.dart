import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/models/reference_stroke.dart';
import 'package:learn_uigarjin/src/models/validation_result.dart';
import 'package:learn_uigarjin/src/validation/stroke_validator.dart';

void main() {
  const validator = StrokeValidator();

  // A simple, mostly-vertical reference stroke shared by several cases.
  final reference = ReferenceStroke(
    order: 1,
    points: [
      for (var i = 0; i <= 20; i++)
        Offset(0.5 + 0.02 * math.sin(i / 3), 0.1 + i * 0.04),
    ],
  );

  const startRadius = 0.1;
  const endRadius = 0.1;
  const tolerance = 0.08;

  StrokeValidationResult run(
    List<Offset> userPoints, {
    ToleranceMode mode = ToleranceMode.beginner,
  }) {
    return validator.validate(
      userPoints: userPoints,
      reference: reference,
      startZoneRadius: startRadius,
      endZoneRadius: endRadius,
      pathTolerance: tolerance,
      mode: mode,
    );
  }

  test('a correct stroke traced closely along the reference is accepted', () {
    final result = run(reference.points);
    expect(result.accepted, isTrue);
    expect(result.reason, StrokeFeedbackReason.correct);
    expect(result.overallScore, greaterThan(90));
  });

  test('a slightly shaky but structurally valid stroke is still accepted', () {
    final shaky = [
      for (var i = 0; i < reference.points.length; i++)
        reference.points[i] +
            Offset(0.012 * (i.isEven ? 1 : -1), 0.006 * (i.isOdd ? 1 : -1)),
    ];
    final result = run(shaky);
    expect(result.accepted, isTrue);
    // Shakiness should cost some points versus a clean trace.
    expect(result.similarityScore, lessThan(100));
  });

  test('a reversed stroke is rejected with the wrongDirection reason', () {
    final reversed = reference.points.reversed.toList();
    final result = run(reversed);
    expect(result.accepted, isFalse);
    expect(result.reason, StrokeFeedbackReason.wrongDirection);
  });

  test('a stroke starting far outside the starting zone is rejected', () {
    final shifted = [
      for (final p in reference.points) p + const Offset(0.4, 0.35),
    ];
    final result = run(shifted);
    expect(result.accepted, isFalse);
    expect(result.reason, StrokeFeedbackReason.startTooFar);
  });

  test('an incomplete stroke that stops partway through is rejected', () {
    final partial = reference.points.sublist(0, 6); // first ~30%
    final result = run(partial);
    expect(result.accepted, isFalse);
    expect(result.reason, StrokeFeedbackReason.incomplete);
  });

  test('advanced mode is stricter than beginner mode', () {
    final shaky = [
      for (var i = 0; i < reference.points.length; i++)
        reference.points[i] +
            Offset(0.02 * (i.isEven ? 1 : -1), 0.01 * (i.isOdd ? 1 : -1)),
    ];
    final beginnerResult = run(shaky, mode: ToleranceMode.beginner);
    final advancedResult = run(shaky, mode: ToleranceMode.advanced);
    expect(
      advancedResult.overallScore,
      lessThanOrEqualTo(beginnerResult.overallScore),
    );
  });

  test('a stroke with almost no length is rejected as incomplete', () {
    final result = run([const Offset(0.5, 0.1), const Offset(0.5, 0.101)]);
    expect(result.accepted, isFalse);
    expect(result.reason, StrokeFeedbackReason.incomplete);
  });
}
