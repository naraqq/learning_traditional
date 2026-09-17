import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/models/character_definition.dart';
import 'package:learn_uigarjin/src/widgets/writing_canvas.dart';
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

/// Trace all practice segments, including detached dots, through real gestures.
Future<void> traceLetter(
  WidgetTester tester,
  CharacterDefinition character,
) async {
  final rect = tester.getRect(find.byType(WritingCanvas));
  Offset point(Offset p) =>
      Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height);
  var milliseconds = 0;
  for (final stroke in character.strokes) {
    final gesture = await tester.startGesture(point(stroke.points.first));
    for (final p in stroke.points.skip(1)) {
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveTo(
        point(p),
        timeStamp: Duration(milliseconds: milliseconds += 16),
      );
    }
    await gesture.up();
    await tester.pumpAndSettle();
    final controller = tester
        .widget<WritingCanvas>(find.byType(WritingCanvas))
        .controller;
    expect(
      controller.currentStrokeIndex,
      stroke.order,
      reason:
          '${character.id}, segment ${stroke.order}: ${controller.feedback}',
    );
  }
}
