# Uigarjin

A Flutter app for practicing traditional Mongolian handwriting. The first development milestone introduces a warm paper-and-teal design, a learning dashboard, sequential lessons, a personal review collection, and device-local progress.

## What works

- **Home:** continue directly into the next form, view collection progress and completed practice counts.
- **Learn:** browse six preview letter forms, inspect their reference shapes, and unlock lessons sequentially.
- **Handwriting:** watch an animated stroke demonstration, trace with finger or stylus, receive geometric feedback, undo/clear strokes, and see a tracing score.
- **Review:** repeat completed forms and view the best tracing score for each.
- **Settings:** persist beginner/advanced guidance, optional accepted-stroke polishing, and haptic feedback.
- **Storage:** completed forms, best scores, completed lesson count, and preferences are saved on the device. Completion is recorded when the results screen opens. Failed writes can be retried; unreadable saved data is preserved instead of silently overwritten.
- **Layouts:** bounded tablet layouts, scrollable small-screen lessons, scalable text, standard focusable primary buttons, and system reduced-motion support for stroke demonstrations.

No account or connection is required for bundled lessons. Progress is not backed up to an app-managed cloud service. Uninstalling the app can remove local data.

## Content status

**This is an early learning edition, not an expert-verified curriculum.** All six bundled forms in `lib/src/data/mongolian_letters.dart` are marked `isDemoData: true`. Their silhouettes were digitized from a reference chart; exact shapes, stroke count, order, direction, and proportions still require review by a traditional Mongolian writing teacher. The app displays this status.

Do not remove those flags merely to make the interface look finished. Add source provenance and reviewer sign-off when replacing or approving content. Full vertical Unicode text shaping, connected words, pronunciation audio, and a complete beginner curriculum are not included yet.

## Run and verify

```sh
flutter pub get
flutter run

dart format lib test tool
flutter analyze
flutter test
flutter build apk --debug
```

The Android debug build is produced at `build/app/outputs/flutter-apk/app-debug.apk`. Store publication and production signing have not been configured. Building iOS requires a macOS development environment.

To export actual Flutter screenshots for design review:

```sh
flutter test tool/design_preview_test.dart --dart-define=FLUTTER_SDK=/absolute/path/to/flutter
```

The exporter loads the SDK's Roboto fonts and writes Home, Learn, Review, Settings, Lesson, and Results PNG files under `build/design/`. It is separate from the normal test suite and does not add screenshot-generation behavior to the application.

The interface bundles Roboto for offline typography, together with its license in `assets/fonts/LICENSE.txt`.

## Structure

```text
lib/src/
  screens/       Home/Learn/Review/Settings shell and handwriting/results
  theme/         Paper, teal, copper, typography, and component styling
  storage/       SharedPreferencesAsync adapter and in-memory test store
  controllers/   Saved learning progress, lesson state, and pointer input
  data/          Six preview letter definitions
  models/        Character forms, reference strokes, and validation results
  geometry/      Resampling, smoothing, and path construction
  validation/    Deterministic geometric stroke scoring
  beautify/      Optional accepted-ink alignment
  painters/      Ink, guides, demonstrations, and miniature glyphs
  widgets/       Writing canvas and reusable lesson controls
```

`AppProgressController` reads a versioned JSON snapshot through `ProgressStore`. Writes are serialized to prevent older saves from overwriting newer state. The platform adapter uses [SharedPreferencesAsync](https://pub.dev/documentation/shared_preferences/latest/shared_preferences/SharedPreferencesAsync-class.html); tests inject an in-memory or failing store. Unknown letter IDs cannot unlock lessons or count as completed.

Stroke coordinates use normalized 0–1 positions. The validator compares start/end position, direction, similarity, and coverage. Scores are geometric tracing feedback, not a validated measure of literacy or independent writing ability. Beginner and advanced modes use different tolerances; the displayed personal best currently combines both modes.

Accepted ink can be aligned toward the reference, but validation always occurs before that optional transformation. Disable “Polish accepted strokes” to keep the learner's resampled handwriting. Cyrillic reference labels remain outside the writing canvas, so they do not compete with the traditional letter guide.

## Tests

Unit and widget tests cover geometry, validation, beautification, lesson completion, sequential unlocking, persistence across controller/app recreation, write failure/retry, malformed stored data, rapid changes, settings, and responsive navigation/lessons at phone and tablet sizes with 100% and 200% text scaling.

Storage tests exercise the adapter contract using test stores. Physical-device persistence, stylus behavior, accessibility with real assistive technology, and iOS builds still need device verification.

## Next milestones

See [ROADMAP.md](ROADMAP.md) for the implementation sequence and remaining release criteria.
