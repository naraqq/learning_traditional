import 'dart:convert';

import 'package:learn_uigarjin/src/storage/progress_store.dart';

/// A [MemoryProgressStore] pre-seeded as if the learner already completed
/// first-run language selection, so tests that aren't specifically about
/// onboarding can jump straight past the splash/language-select screens to
/// the main app content — matching what these tests asserted before those
/// screens existed.
MemoryProgressStore onboardedStore({String languageCode = 'en'}) {
  return MemoryProgressStore()
    ..value = jsonEncode({
      'version': 1,
      'completed': <String>[],
      'scores': <String, double>{},
      'practiceCount': 0,
      'settings': {
        'beginner': true,
        'beautify': true,
        'haptics': true,
        'languageCode': languageCode,
        'languageChosen': true,
      },
    });
}
