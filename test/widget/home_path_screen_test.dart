import '../test_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/screens/home_path_screen.dart';
import 'package:learn_uigarjin/src/screens/lesson_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );

  // The next-up path node pulses with a perpetually repeating animation
  // (deliberately skipped when reduced motion is requested — see
  // LetterPathNode). Simulating reduced motion at the platform level here
  // keeps these tests deterministic: an always-animating widget would
  // otherwise never let pumpAndSettle() converge.
  void requestReducedMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  testWidgets(
    'home path shows all letters with the first unlocked and rest locked',
    (tester) async {
      requestReducedMotion(tester);
      await tester.pumpWidget(wrap(HomePathScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Mongolian Script'), findsOneWidget);
      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      // Some letters (e.g. N) appear twice — once per form — so assert
      // label counts by frequency rather than assuming uniqueness.
      final labelCounts = <String, int>{};
      for (final letter in mongolianLetters) {
        final label = '${letter.cyrillic} · ${letter.transliteration}';
        labelCounts[label] = (labelCounts[label] ?? 0) + 1;
      }
      for (final entry in labelCounts.entries) {
        expect(find.text(entry.key), findsNWidgets(entry.value));
      }
      // First letter unlocked (no lock icon on its node); the rest show locks.
      expect(
        find.byIcon(Icons.lock_rounded),
        findsNWidgets(mongolianLetters.length - 1),
      );
    },
  );

  testWidgets('tapping a locked node shows a hint instead of navigating', (
    tester,
  ) async {
    requestReducedMotion(tester);
    await tester.pumpWidget(wrap(HomePathScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(Key('node_${mongolianLetters[1].id}')),
    );
    await tester.tap(find.byKey(Key('node_${mongolianLetters[1].id}')));
    await tester.pump();

    expect(
      find.textContaining('Complete the letter before this one'),
      findsOneWidget,
    );
    expect(find.byType(LessonScreen), findsNothing);
  });

  testWidgets(
    'completing the first letter unlocks the second and updates the progress pill',
    (tester) async {
      requestReducedMotion(tester);
      await tester.pumpWidget(wrap(HomePathScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(Key('node_${mongolianLetters[0].id}')),
      );
      await tester.tap(find.byKey(Key('node_${mongolianLetters[0].id}')));
      await tester.pumpAndSettle();
      expect(find.byType(LessonScreen), findsOneWidget);

      await traceLetter(tester, mongolianLetters[0]);

      await tester.ensureVisible(find.byKey(const Key('continueButton')));
      await tester.tap(find.byKey(const Key('continueButton')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('celebrationContinueButton')),
      );
      await tester.tap(find.byKey(const Key('celebrationContinueButton')));
      await tester.pumpAndSettle();

      expect(find.byType(LessonScreen), findsNothing);
      expect(find.text('1/${mongolianLetters.length}'), findsOneWidget);
      // One fewer locked node now that the second letter has unlocked.
      expect(
        find.byIcon(Icons.lock_rounded),
        findsNWidgets(mongolianLetters.length - 2),
      );
    },
  );
}
