import 'dart:ui';
import 'reference_stroke.dart';

/// Where in a word this character form appears. Traditional Mongolian
/// (Hudum) script is contextual: a letter's shape changes depending on its
/// position in the word.
enum CharacterForm { isolated, initial, medial, final_ }

/// Reusable data model describing one traditional Mongolian-script
/// character/letter form and everything the lesson engine needs to teach
/// and validate its handwriting.
class CharacterDefinition {
  const CharacterDefinition({
    required this.id,
    required this.displayName,
    required this.cyrillic,
    required this.transliteration,
    required this.form,
    required this.strokes,
    required this.startZoneRadius,
    required this.endZoneRadius,
    required this.pathTolerance,
    required this.recommendedBrushWidth,
    this.isDemoData = false,
    this.expertReviewNote,
    this.outlineContours = const [],
    this.recognitionGroup,
    this.alternate = false,
  });

  /// Filled ink contours transcribed from the reference chart, in the same
  /// normalized square coordinates as the tracing segments. Even-odd fill
  /// preserves counters (holes) inside looped letters.
  final List<List<Offset>> outlineContours;

  /// Forms with identical visible shapes share a recognition answer.
  final String? recognitionGroup;
  final bool alternate;

  /// Stable identifier, e.g. `n_initial`.
  final String id;

  /// Human readable name shown in the lesson header, e.g. "N — Initial form".
  final String displayName;

  /// The letter's modern Cyrillic Mongolian equivalent, e.g. "Н". Shown on
  /// path nodes and in the lesson header alongside the traditional glyph.
  final String cyrillic;

  /// Latin transliteration, e.g. "N".
  final String transliteration;

  /// Positional form this stroke data represents.
  final CharacterForm form;

  /// Ordered reference strokes that make up the character.
  final List<ReferenceStroke> strokes;

  /// Default radius (normalized units, fraction of the writing sheet's
  /// shortest side) of the "correct start" zone around a stroke's first
  /// point. Individual strokes may override this.
  final double startZoneRadius;

  /// Default radius (normalized units) of the "correct end" zone.
  final double endZoneRadius;

  /// Maximum acceptable average deviation (normalized units) between the
  /// learner's path and the reference path before it stops counting as
  /// "similar enough".
  final double pathTolerance;

  /// Suggested ink stroke width, normalized to the canvas's shortest side.
  final double recommendedBrushWidth;

  /// True when [strokes] are placeholder/demonstration geometry rather than
  /// linguistically verified traditional Mongolian stroke data.
  final bool isDemoData;

  /// Explains what still needs expert review when [isDemoData] is true.
  final String? expertReviewNote;
}
