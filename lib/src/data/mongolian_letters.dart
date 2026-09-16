import 'dart:ui';

import '../models/character_definition.dart';
import '../models/reference_stroke.dart';

/// ---------------------------------------------------------------------
/// REAL LETTERFORMS — STROKE ORDER STILL PENDING EXPERT REVIEW
/// ---------------------------------------------------------------------
/// Each letter's overall silhouette (stem plus its teeth/hooks/loops) was
/// hand-digitized to match a standard traditional Mongolian (Hudum) script
/// reference chart showing Initial/Medial/Final consonant forms with their
/// Cyrillic and Latin equivalents. The general shapes and proportions are
/// therefore based on real letterforms, not invented — but the exact
/// stroke *order*, *count* and vector path were approximated by eye from a
/// static reference image, not traced from authoritative calligraphy
/// stroke-order data. Every [CharacterDefinition] below keeps
/// `isDemoData: true` and an `expertReviewNote` until a qualified
/// Mongolian-script/calligraphy expert has verified stroke order,
/// direction and proportions.
/// ---------------------------------------------------------------------

const String _reviewNote =
    'Letterform silhouette digitized by eye from a standard traditional '
    'Mongolian (Hudum) script reference chart. The shape is based on a '
    'real letter, but exact stroke order, count and proportions have not '
    'yet been verified by a Mongolian-script/calligraphy expert.';

CharacterDefinition _letter({
  required String id,
  required String displayName,
  required String cyrillic,
  required String transliteration,
  required CharacterForm form,
  required List<ReferenceStroke> strokes,
}) {
  return CharacterDefinition(
    id: id,
    displayName: displayName,
    cyrillic: cyrillic,
    transliteration: transliteration,
    form: form,
    strokes: strokes,
    startZoneRadius: 0.11,
    endZoneRadius: 0.11,
    pathTolerance: 0.10,
    recommendedBrushWidth: 0.022,
    isDemoData: true,
    expertReviewNote: _reviewNote,
  );
}

/// N — Initial form: a single continuous stroke, small hook at the top
/// flowing into the stem.
final CharacterDefinition letterNInitial = _letter(
  id: 'n_initial',
  displayName: 'N — Initial form',
  cyrillic: 'Н',
  transliteration: 'N',
  form: CharacterForm.initial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.58, 0.08),
        Offset(0.44, 0.11),
        Offset(0.40, 0.15),
        Offset(0.48, 0.19),
        Offset(0.52, 0.22),
        Offset(0.50, 0.45),
        Offset(0.49, 0.65),
        Offset(0.51, 0.90),
      ],
    ),
  ],
);

/// N — Medial form: the stem, then a small tooth flicked off partway down —
/// shows how the same letter's shape changes with its position in a word.
final CharacterDefinition letterNMedial = _letter(
  id: 'n_medial',
  displayName: 'N — Medial form',
  cyrillic: 'Н',
  transliteration: 'N',
  form: CharacterForm.medial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.50, 0.08),
        Offset(0.50, 0.30),
        Offset(0.50, 0.50),
        Offset(0.50, 0.70),
        Offset(0.50, 0.90),
      ],
    ),
    ReferenceStroke(
      order: 2,
      points: const [
        Offset(0.50, 0.42),
        Offset(0.41, 0.45),
        Offset(0.50, 0.49),
      ],
    ),
  ],
);

/// B — Initial form: a loop at the top opening into the stem.
final CharacterDefinition letterBInitial = _letter(
  id: 'b_initial',
  displayName: 'B — Initial form',
  cyrillic: 'Б',
  transliteration: 'B',
  form: CharacterForm.initial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.50, 0.08),
        Offset(0.62, 0.10),
        Offset(0.66, 0.15),
        Offset(0.58, 0.20),
        Offset(0.50, 0.22),
        Offset(0.50, 0.45),
        Offset(0.50, 0.65),
        Offset(0.50, 0.90),
      ],
    ),
  ],
);

/// M — Initial form: the stem plus two small teeth — a good multi-stroke
/// demonstration exercise.
final CharacterDefinition letterMInitial = _letter(
  id: 'm_initial',
  displayName: 'M — Initial form',
  cyrillic: 'М',
  transliteration: 'M',
  form: CharacterForm.initial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.50, 0.08),
        Offset(0.50, 0.30),
        Offset(0.50, 0.55),
        Offset(0.50, 0.75),
        Offset(0.50, 0.90),
      ],
    ),
    ReferenceStroke(
      order: 2,
      points: const [
        Offset(0.50, 0.30),
        Offset(0.40, 0.33),
        Offset(0.50, 0.36),
      ],
    ),
    ReferenceStroke(
      order: 3,
      points: const [
        Offset(0.50, 0.46),
        Offset(0.40, 0.49),
        Offset(0.50, 0.52),
      ],
    ),
  ],
);

/// L — Initial form: the stem curling into a small hook at the foot.
final CharacterDefinition letterLInitial = _letter(
  id: 'l_initial',
  displayName: 'L — Initial form',
  cyrillic: 'Л',
  transliteration: 'L',
  form: CharacterForm.initial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.50, 0.08),
        Offset(0.50, 0.35),
        Offset(0.50, 0.60),
        Offset(0.50, 0.78),
        Offset(0.44, 0.87),
        Offset(0.38, 0.90),
        Offset(0.40, 0.94),
      ],
    ),
  ],
);

/// G — Initial form: an angular hook at the top flowing into the stem.
final CharacterDefinition letterGInitial = _letter(
  id: 'g_initial',
  displayName: 'G — Initial form',
  cyrillic: 'Г',
  transliteration: 'G',
  form: CharacterForm.initial,
  strokes: [
    ReferenceStroke(
      order: 1,
      points: const [
        Offset(0.50, 0.08),
        Offset(0.63, 0.09),
        Offset(0.64, 0.13),
        Offset(0.52, 0.17),
        Offset(0.50, 0.20),
        Offset(0.50, 0.45),
        Offset(0.50, 0.65),
        Offset(0.50, 0.90),
      ],
    ),
  ],
);

/// All letters, in the order they unlock on the home path.
final List<CharacterDefinition> mongolianLetters = [
  letterNInitial,
  letterNMedial,
  letterBInitial,
  letterMInitial,
  letterLInitial,
  letterGInitial,
];
