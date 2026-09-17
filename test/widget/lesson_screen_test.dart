import '../test_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/screens/lesson_screen.dart';
import 'package:learn_uigarjin/src/widgets/primary_action_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );

  testWidgets('lesson screen loads with all key controls', (tester) async {
    await tester.pumpWidget(wrap(LessonScreen(character: letterNInitial)));
    await tester.pumpAndSettle();

    expect(find.text('HANDWRITING PRACTICE'), findsOneWidget);
    expect(find.byKey(const Key('lessonCloseButton')), findsOneWidget);
    expect(find.byKey(const Key('undoButton')), findsOneWidget);
    expect(find.byKey(const Key('clearButton')), findsOneWidget);
    expect(find.byKey(const Key('showAgainButton')), findsOneWidget);
    expect(find.byKey(const Key('continueButton')), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    // Real letterform data must still be clearly disclosed as pending
    // expert review of stroke order.
    expect(find.textContaining('pending expert review'), findsOneWidget);

    // Continue is disabled until the exercise is complete.
    final continueButton = tester.widget<PrimaryActionButton>(
      find.byKey(const Key('continueButton')),
    );
    expect(continueButton.onPressed, isNull);
  });

  testWidgets('Clear and Show again controls can be tapped without error', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LessonScreen(character: letterNInitial)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('clearButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('showAgainButton')));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(find.text('HANDWRITING PRACTICE'), findsOneWidget);
  });

  testWidgets('tolerance toggle switches between beginner and advanced', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(LessonScreen(character: letterNInitial)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();

    // No exceptions thrown means the toggle wiring works end to end.
    expect(find.text('HANDWRITING PRACTICE'), findsOneWidget);
  });

  testWidgets(
    'drawing the reference stroke is accepted and unlocks the celebration',
    (tester) async {
      await tester.pumpWidget(wrap(LessonScreen(character: letterNInitial)));
      await tester.pumpAndSettle();

      await traceLetter(tester, letterNInitial);

      expect(find.textContaining('Correct'), findsOneWidget);

      // With all letter segments complete, Continue unlocks.
      final continueButton = tester.widget<PrimaryActionButton>(
        find.byKey(const Key('continueButton')),
      );
      expect(continueButton.onPressed, isNotNull);

      // Tapping it reveals the completion celebration...
      await tester.ensureVisible(find.byKey(const Key('continueButton')));
      await tester.tap(find.byKey(const Key('continueButton')));
      await tester.pumpAndSettle();
      expect(find.text('Well done!'), findsOneWidget);

      // ...and its own button is present to pop the screen with a
      // completion result.
      expect(
        find.byKey(const Key('celebrationContinueButton')),
        findsOneWidget,
      );
    },
  );
}
