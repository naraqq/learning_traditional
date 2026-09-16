import '../models/lesson_feedback.dart';
import 'dart:ui';

import '../geometry/geometry_utils.dart';
import '../models/reference_stroke.dart';
import '../models/validation_result.dart';

/// Beginner mode uses more forgiving thresholds; advanced mode expects
/// closer adherence to the reference stroke.
enum ToleranceMode { beginner, advanced }

/// Deterministic, local stroke validator. No machine learning: every score
/// comes from explicit geometric comparisons so behaviour is predictable
/// and testable.
class StrokeValidator {
  const StrokeValidator();

  /// Both strokes are resampled to this many points before comparison so
  /// index `i` on one stroke lines up with index `i` on the other.
  static const int resampleCount = 32;

  StrokeValidationResult validate({
    required List<Offset> userPoints,
    required ReferenceStroke reference,
    required double startZoneRadius,
    required double endZoneRadius,
    required double pathTolerance,
    required ToleranceMode mode,
  }) {
    if (userPoints.length < 2 || GeometryUtils.pathLength(userPoints) < 0.02) {
      return _zeroResult(
        StrokeFeedbackReason.incomplete,
        LessonFeedback.incomplete,
      );
    }

    // Beginner mode is deliberately forgiving: shaky handwriting should
    // still pass as long as the underlying stroke is correct.
    final toleranceMultiplier = mode == ToleranceMode.beginner ? 1.6 : 1.0;
    final effectiveStartRadius = startZoneRadius * toleranceMultiplier;
    final effectiveEndRadius = endZoneRadius * toleranceMultiplier;
    final effectiveTolerance = pathTolerance * toleranceMultiplier;

    final userResampled = GeometryUtils.resample(userPoints, resampleCount);
    final refResampled = GeometryUtils.resample(
      reference.points,
      resampleCount,
    );

    final startDist = GeometryUtils.distance(
      userResampled.first,
      refResampled.first,
    );
    final endDist = GeometryUtils.distance(
      userResampled.last,
      refResampled.last,
    );
    final startScore = _zoneScore(startDist, effectiveStartRadius);
    final endScore = _zoneScore(endDist, effectiveEndRadius);

    // Direction: an aligned (forward) comparison is cheap versus a
    // reversed comparison. Whichever orientation fits better tells us
    // whether the learner drew the stroke forwards or backwards.
    final reversedUser = userResampled.reversed.toList();
    final alignedCost = GeometryUtils.averagePointDistance(
      userResampled,
      refResampled,
    );
    final reversedCost = GeometryUtils.averagePointDistance(
      reversedUser,
      refResampled,
    );
    final directionScore = (alignedCost + reversedCost) == 0
        ? 100.0
        : (100 * reversedCost / (alignedCost + reversedCost)).clamp(0.0, 100.0);
    final isReversed = reversedCost < alignedCost * 0.85;

    final similarityScore = _toleranceScore(alignedCost, effectiveTolerance);
    final coverageScore =
        GeometryUtils.coverageFraction(
          refResampled,
          userResampled,
          effectiveTolerance,
        ) *
        100;

    final overall =
        (startScore * 0.2 +
                endScore * 0.2 +
                directionScore * 0.2 +
                similarityScore * 0.25 +
                coverageScore * 0.15)
            .clamp(0.0, 100.0);

    final passThreshold = mode == ToleranceMode.beginner ? 58.0 : 72.0;

    if (isReversed) {
      return _result(
        overall,
        startScore,
        endScore,
        directionScore,
        similarityScore,
        coverageScore,
        false,
        StrokeFeedbackReason.wrongDirection,
        LessonFeedback.wrongDirection,
      );
    }
    if (startDist > effectiveStartRadius * 2.2) {
      return _result(
        overall,
        startScore,
        endScore,
        directionScore,
        similarityScore,
        coverageScore,
        false,
        StrokeFeedbackReason.startTooFar,
        _startHint(userResampled.first, refResampled.first),
      );
    }
    if (coverageScore < 50) {
      return _result(
        overall,
        startScore,
        endScore,
        directionScore,
        similarityScore,
        coverageScore,
        false,
        StrokeFeedbackReason.incomplete,
        LessonFeedback.incompleteToEnd,
      );
    }
    if (overall < passThreshold) {
      return _result(
        overall,
        startScore,
        endScore,
        directionScore,
        similarityScore,
        coverageScore,
        false,
        StrokeFeedbackReason.lowSimilarity,
        LessonFeedback.lowSimilarity,
      );
    }
    return _result(
      overall,
      startScore,
      endScore,
      directionScore,
      similarityScore,
      coverageScore,
      true,
      StrokeFeedbackReason.correct,
      LessonFeedback.correct,
    );
  }

  /// 100 at dist=0, 70 at the zone edge, decaying to 0 by twice the radius.
  static double _zoneScore(double dist, double radius) {
    final r = radius <= 0 ? 0.05 : radius;
    final ratio = dist / r;
    if (ratio <= 1) return 100 - ratio * 30;
    final over = ratio - 1;
    return (70 - over * 70).clamp(0.0, 70.0);
  }

  /// 100 at zero deviation, 80 at the tolerance edge, decaying to 0 as
  /// deviation grows further.
  static double _toleranceScore(double avgDist, double tolerance) {
    final t = tolerance <= 0 ? 0.05 : tolerance;
    final ratio = avgDist / t;
    if (ratio <= 1) return 100 - ratio * 20;
    final over = ratio - 1;
    return (80 - over * 60).clamp(0.0, 80.0);
  }

  static LessonFeedback _startHint(Offset userStart, Offset refStart) {
    final dx = userStart.dx - refStart.dx;
    final dy = userStart.dy - refStart.dy;
    if (dy.abs() > dx.abs()) {
      return dy < 0 ? LessonFeedback.startLower : LessonFeedback.startHigher;
    }
    return dx < 0 ? LessonFeedback.startRight : LessonFeedback.startLeft;
  }

  StrokeValidationResult _zeroResult(
    StrokeFeedbackReason reason,
    LessonFeedback feedback,
  ) {
    return StrokeValidationResult(
      overallScore: 0,
      startScore: 0,
      endScore: 0,
      directionScore: 0,
      similarityScore: 0,
      coverageScore: 0,
      accepted: false,
      reason: reason,
      feedback: feedback,
    );
  }

  StrokeValidationResult _result(
    double overall,
    double start,
    double end,
    double direction,
    double similarity,
    double coverage,
    bool accepted,
    StrokeFeedbackReason reason,
    LessonFeedback feedback,
  ) {
    return StrokeValidationResult(
      overallScore: overall,
      startScore: start,
      endScore: end,
      directionScore: direction,
      similarityScore: similarity,
      coverageScore: coverage,
      accepted: accepted,
      reason: reason,
      feedback: feedback,
    );
  }
}
