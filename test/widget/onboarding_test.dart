import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/main.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';

void main() {
  testWidgets(
    'first launch shows the splash then the language picker before Home',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      final store = MemoryProgressStore();
      await tester.pumpWidget(MongolianHandwritingApp(store: store));

      // Splash is up on the very first frame — its own title, not Home's
      // navigation bar (which only appears once we're past onboarding).
      await tester.pump();
      expect(find.text('Mongolian Script'), findsOneWidget);
      expect(find.text('Home'), findsNothing);

      // Once ready, a learner who has never chosen a language sees the
      // picker rather than Home.
      await tester.pumpAndSettle();
      expect(find.text('Choose your language'), findsOneWidget);
      expect(find.text('Home'), findsNothing);

      await tester.tap(find.byKey(const Key('languageOption_mn')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('languageContinueButton')));
      await tester.pumpAndSettle();

      // Lands on Home, in the chosen language, and the choice is persisted.
      expect(find.text('Нүүр'), findsOneWidget);
      final saved = jsonDecode(store.value!) as Map<String, dynamic>;
      expect(saved['settings']['languageChosen'], isTrue);
      expect(saved['settings']['languageCode'], 'mn');
    },
  );

  testWidgets('a learner who already chose a language skips straight to Home', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    final store = MemoryProgressStore()
      ..value = jsonEncode({
        'version': 1,
        'completed': <String>[],
        'scores': <String, double>{},
        'practiceCount': 0,
        'settings': {
          'beginner': true,
          'beautify': true,
          'haptics': true,
          'languageCode': 'en',
          'languageChosen': true,
        },
      });

    await tester.pumpWidget(MongolianHandwritingApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('Mongolian Script'), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
  });
}
