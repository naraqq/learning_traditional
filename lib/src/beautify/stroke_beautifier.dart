import 'dart:ui';

import '../geometry/geometry_utils.dart';

/// Produces a corrected version of an accepted stroke by blending the
/// learner's own smoothed input toward the reference centerline, so the
/// visible ink converges on the clean "placeholder" letterform the learner
/// was tracing rather than staying as raw, wobbly input.
///
/// The blend strength is confidence-based: input that was already close to
/// the reference (high similarity) is pulled in firmly but keeps a light
/// personal touch, while shakier-but-still-valid input is pulled almost all
/// the way to the template so the result reads as a clean version of the
/// letter. This class is only ever invoked for strokes the validator has
/// already accepted — it does not (and must not) turn an incorrect stroke
/// into a correct-looking one.
class StrokeBeautifier {
  const StrokeBeautifier();

  /// Both the learner and reference strokes are resampled to this many
  /// points so corresponding positions along each centerline line up.
  static const int pointCount = 32;

  /// Returns beautified points in the same normalized space as the inputs,
  /// always clamped to the unit square.
  List<Offset> beautify({
    required List<Offset> userPoints,
    required List<Offset> referencePoints,
    required double similarityScore,
  }) {
    final user = GeometryUtils.resample(userPoints, pointCount);
    final ref = GeometryUtils.resample(referencePoints, pointCount);
    final blend = blendFactorFor(similarityScore);
    return [
      for (var i = 0; i < pointCount; i++)
        GeometryUtils.clampUnit(Offset.lerp(user[i], ref[i], blend)!),
    ];
  }

  /// Maps a 0-100 similarity score to a 0.0-1.0 blend-toward-reference
  /// factor. Higher similarity (already close to the reference) yields a
  /// smaller factor -> the result still reads as the clean reference glyph
  /// but keeps a light personal touch. Lower similarity (shaky but still
  /// valid, since this is only called on accepted strokes) yields a factor
  /// close to 1.0 -> the result converges almost entirely onto the
  /// reference. The result is clamped below 1.0 so a sliver of personal
  /// variation always survives and correction is never a total replacement.
  double blendFactorFor(double similarityScore) {
    final s = similarityScore.clamp(0.0, 100.0) / 100;
    final factor = 0.97 - s * 0.27;
    return factor.clamp(0.70, 0.97);
  }
}
