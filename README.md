# learn_uigarjin — Mongolian Script Handwriting Practice (Prototype)

A Duolingo-style handwriting-practice app for traditional Mongolian (Hudum)
script, built with plain Flutter/Dart: `CustomPainter`, `Canvas`, `Path` and
low-level pointer events. No Unity, no WebView, no bitmap-based ink.

A home screen shows a winding path of letter nodes (locked → available →
completed, like a language-learning app's unit map). Tapping an unlocked
letter opens a full handwriting lesson: trace the reference strokes, get a
live-corrected version of your own ink, and finish with a starred
celebration screen before returning to the path.

> ⚠️ **Stroke data disclaimer.** The six bundled letters are digitized from
> a real traditional Mongolian script reference chart (Initial/Medial/Final
> consonant forms with Cyrillic/Latin equivalents), so their shapes are
> based on real letterforms, not invented. However, the exact stroke
> *order*, *count* and vector path were approximated by eye from a static
> image, not traced from authoritative calligraphy stroke-order data. See
> [Letter data requiring expert review](#letter-data-requiring-expert-review)
> before using this for real instruction.

## How to run the prototype

```bash
flutter pub get
flutter run
```

The app opens into the home path screen (`lib/main.dart` →
`HomePathScreen`) with six letter nodes; the first is unlocked. Tap it to
open the lesson (`LessonScreen`) and draw with a finger, mouse, or stylus.
Completing a letter's exercise unlocks the next node on the path.

To run checks:

```bash
dart format lib test
flutter analyze
flutter test
```

## Project structure

```
lib/src/
  models/        Data model: CharacterDefinition, ReferenceStroke, CompletedStroke, StrokeValidationResult
  data/          mongolian_letters.dart — the 6 bundled letters (clearly marked, review pending)
  geometry/      Pure, unit-testable algorithms: resampling, smoothing, path building
  validation/    Deterministic StrokeValidator (no ML)
  beautify/      StrokeBeautifier — blends accepted input toward the reference
  controllers/   LessonController (exercise state), ActiveStrokeController (live capture),
                 AppProgressController (which letters are unlocked/completed)
  theme/         AppTheme / AppColors — the app's design system
  painters/      CustomPainters for the reference guide, completed ink, active stroke,
                 demo animation, reject flash, and the path screen's mini glyph previews
  widgets/       WritingCanvas (capture + compositing), PrimaryActionButton, LetterPathNode,
                 and other small UI pieces
  screens/       HomePathScreen (letter path/map) and LessonScreen (the lesson + celebration)
```

Geometry, validation and beautification are plain Dart classes with no
Flutter widget dependencies, so they're covered directly by unit tests in
`test/geometry`, `test/validation` and `test/beautify`. `test/widget`
covers the lesson screen and the home path screen, including a simulated
finger-drag stroke and full letter-unlock flow.

## How the normalized stroke format works

Every `ReferenceStroke.points` list uses **normalized coordinates**: `dx`
and `dy` each range from `0.0` to `1.0`, regardless of the device's actual
screen size. `SmoothPathBuilder.denormalize()` multiplies by the writing
sheet's pixel `Size` right before painting, so the same `CharacterDefinition`
scales correctly to any phone or tablet.

The same normalization applies to captured input: `WritingCanvas` divides
every pointer sample's local position by the canvas size before it touches
any geometry, smoothing, validation or beautification code — so all of
those layers only ever operate in the 0.0–1.0 unit square.

## How to add another character

1. Open `lib/src/data/mongolian_letters.dart`.
2. Create a new `CharacterDefinition` (the private `_letter()` helper fills
   in the shared zone/tolerance/brush defaults and the review disclaimer):
   - `id`, `displayName`, `cyrillic`, `transliteration`, `form`
     (`isolated` / `initial` / `medial` / `final_`).
   - `strokes`: an ordered list of `ReferenceStroke(order: ..., points: [...])`,
     each `points` list being the centerline of that stroke in normalized
     coordinates, in drawing order (first point = where the pen touches
     down, last point = where it lifts).
   - `startZoneRadius`, `endZoneRadius`, `pathTolerance`,
     `recommendedBrushWidth` — all normalized (fraction of the canvas's
     shortest side). The bundled letters use `0.11` for the zones and
     `0.10` for tolerance as a reasonable beginner-friendly starting point.
   - Keep `isDemoData: true` and a real `expertReviewNote` until the shape
     and stroke order have been checked by a Mongolian-script expert.
3. Add the new `CharacterDefinition` to the `mongolianLetters` list — it
   will automatically appear as the next node on the home path.

No other code changes are required — the validator, beautifier, path
screen and all painters work off this data generically.

## How validation scoring works

`StrokeValidator` (in `lib/src/validation/stroke_validator.dart`) is fully
deterministic — no machine learning. For each submitted stroke:

1. Both the learner's stroke and the expected reference stroke are
   resampled to the same number of arc-length-spaced points
   (`GeometryUtils.resample`), so point `i` on one lines up with point `i`
   on the other.
2. **Start score** / **end score** — distance from the learner's first/last
   point to the reference's first/last point, scored against the stroke's
   start/end zone radius (100 at dead center, decaying to 0 by twice the
   radius).
3. **Direction score** — the average point-to-point distance is computed
   both in forward order and with the learner's stroke reversed. Whichever
   orientation fits better indicates whether the stroke was drawn forwards
   or backwards; a clearly-better reversed fit rejects the stroke outright
   as `wrongDirection`.
4. **Similarity score** — the forward-aligned average deviation, scored
   against `pathTolerance`.
5. **Coverage score** — the fraction of reference points that have some
   learner point within tolerance of them, catching strokes that stop
   partway through.
6. These combine into a weighted **overall score (0–100)**
   (20% start, 20% end, 20% direction, 25% similarity, 15% coverage). This
   score also drives the 1–3 star rating on the lesson-complete celebration
   (via `LessonController.averageScore`).

**Beginner mode** multiplies all zone radii and tolerances by 1.6× and uses
a lower pass threshold (58 vs. 72), so natural shakiness is accepted as
long as the underlying stroke — start point, end point, direction, and
overall shape — is correct. A stroke is rejected (with a specific reason:
`startTooFar`, `wrongDirection`, `incomplete`, or `lowSimilarity`) before
ever being accepted purely for being messy.

## How beautification works

`StrokeBeautifier` (in `lib/src/beautify/stroke_beautifier.dart`) only runs
on strokes the validator has already **accepted** — it never turns an
incorrect stroke into a correct-looking one. Its job is to make the
accepted ink read as the clean reference letterform the learner was
tracing, while still keeping a trace of their own hand.

1. The learner's raw (lightly smoothed) points and the reference stroke are
   both resampled to the same point count, so corresponding positions along
   each centerline line up index-for-index.
2. Each pair of points is blended with `Offset.lerp(user, reference, blend)`,
   where `blend` is a confidence-based factor derived from the stroke's
   similarity score (`blendFactorFor`):
   - High similarity (clean input) → blend ≈ 0.70 → the result converges
     firmly onto the reference shape but keeps a light personal touch.
   - Lower similarity that still passed validation (shaky-but-correct) →
     blend up to 0.97 → the result reads as essentially the clean
     reference letterform, correcting even a rough approximation (e.g. a
     near-straight swipe) into its proper hooked/looped shape.
   - The factor is clamped below 1.0 so it is never a total replacement.
3. `LessonController` stores both the pre-beautify (`rawPoints`) and
   post-beautify (`beautifiedPoints`) versions on the `CompletedStroke`, and
   `WritingCanvas` runs a 200ms `AnimationController` that calls
   `updateBeautifyProgress(t)` every tick, linearly interpolating the
   displayed ink from raw to beautified. Reduced-motion users get the
   beautified result immediately instead of an animation.

## Letter data requiring expert review

All six bundled letters in `lib/src/data/mongolian_letters.dart`
(`n_initial`, `n_medial`, `b_initial`, `m_initial`, `l_initial`,
`g_initial`) have shapes digitized by eye from a standard traditional
Mongolian (Hudum) script reference chart — so proportions and general
silhouette (stem, hooks, loops, teeth) are based on real letterforms, not
invented. Exact stroke order, stroke count and vector path have **not**
been verified by a Mongolian-script/calligraphy expert. Each carries
`isDemoData: true` and an `expertReviewNote`, and the lesson screen shows a
visible "Real letterform, stroke order pending expert review" banner
whenever one is loaded. Replace or refine this data before using the app
to teach real orthography.

## Known limitations

- Letter stroke order is unverified (see above).
- Progress (which letters are unlocked/completed) is in-memory only via
  `AppProgressController` — it resets on app restart. No new package was
  added to persist it; wiring in `shared_preferences` (or similar) would be
  the natural next step.
- Validation and beautification operate purely on 2D point geometry; they
  do not model brush pressure/width as part of correctness (pressure is
  captured and can subtly affect rendered ink width, but is not scored).
- Only six letters/forms are included; the home path is built to add more
  by simply appending to `mongolianLetters`.
