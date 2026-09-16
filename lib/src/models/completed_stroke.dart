import 'dart:ui';

/// A stroke the learner has successfully completed, tracked through
/// validation and beautification.
class CompletedStroke {
  CompletedStroke({
    required this.strokeOrder,
    required this.rawPoints,
    required this.beautifiedPoints,
    required this.accepted,
    this.widthScale = 1.0,
    this.score = 100,
  }) : displayPoints = List<Offset>.of(rawPoints);

  /// Matches [ReferenceStroke.order].
  final int strokeOrder;

  /// The learner's smoothed input, resampled to a fixed point count so it
  /// lines up index-for-index with [beautifiedPoints] for animation.
  final List<Offset> rawPoints;

  /// The beautified (reference-blended) version of the stroke.
  final List<Offset> beautifiedPoints;

  final bool accepted;

  /// Subtle brush-width multiplier derived from stylus pressure while this
  /// stroke was drawn (1.0 when pressure wasn't available).
  final double widthScale;

  /// The validator's overall score (0-100) for this stroke, used to derive
  /// a star rating on the lesson-complete celebration.
  final double score;

  /// Currently rendered points. Interpolates from [rawPoints] to
  /// [beautifiedPoints] while the beautification animation plays, then
  /// settles on [beautifiedPoints].
  List<Offset> displayPoints;
}
