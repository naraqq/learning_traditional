import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/painters/mini_glyph_painter.dart';
import 'package:learn_uigarjin/src/screens/challenge_screen.dart';
import 'package:learn_uigarjin/src/screens/home_path_screen.dart';
import '../test_support.dart';

void main() {
  Widget wrap(Widget child, {String locale = 'en'}) => MaterialApp(
    locale: Locale(locale),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );

  final quizLetters = [
    letterNInitial,
    letterNMedial,
    letterBInitial,
    letterMInitial,
    letterLInitial,
    letterGInitial,
  ];

  testWidgets('round has unique choices, scores once, finishes and resets', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ChallengeScreen(letters: quizLetters)));
    final seen = <String>{};
    for (var i = 0; i < quizLetters.length; i++) {
      final painter =
          tester
                  .widget<CustomPaint>(find.byKey(const Key('challengeGlyph')))
                  .painter!
              as MiniGlyphPainter;
      seen.add(painter.character.id);
      expect(find.byType(OutlinedButton), findsNWidgets(4));
      final labels = tester
          .widgetList<OutlinedButton>(find.byType(OutlinedButton))
          .map((b) => b.key)
          .toSet();
      expect(labels.length, 4);
      final correct = find.byKey(Key('answer_${painter.character.cyrillic}'));
      final choice = i == 0
          ? find
                .byType(OutlinedButton)
                .evaluate()
                .map((e) => e.widget as OutlinedButton)
                .firstWhere(
                  (b) => b.key != Key('answer_${painter.character.cyrillic}'),
                )
                .key!
          : Key('answer_${painter.character.cyrillic}');
      await tester.ensureVisible(find.byKey(choice));
      await tester.tap(find.byKey(choice));
      await tester.pump();
      expect(tester.widget<OutlinedButton>(correct).onPressed, isNull);
      if (i == 0) {
        expect(find.textContaining('Correct answer:'), findsOneWidget);
      }
      await tester.ensureVisible(find.byKey(const Key('challengeNext')));
      await tester.tap(find.byKey(const Key('challengeNext')));
      await tester.pumpAndSettle();
    }
    expect(seen.length, quizLetters.length);
    expect(find.text('5 of 6 correct'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('challengeAgain')));
    await tester.tap(find.byKey(const Key('challengeAgain')));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 6'), findsOneWidget);
    expect(find.byKey(const Key('challengeNext')), findsNothing);
  });

  testWidgets('home launches challenge and back preserves lesson progress', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(HomePathScreen(store: onboardedStore())));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('startChallengeButton')));
    await tester.tap(find.byKey(const Key('startChallengeButton')));
    await tester.pumpAndSettle();
    expect(find.byType(ChallengeScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('0/${mongolianLetters.length}'), findsOneWidget);
  });

  testWidgets('Mongolian quiz fits narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      wrap(ChallengeScreen(letters: mongolianLetters), locale: 'mn'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Энэ ямар үсэг вэ?'), findsOneWidget);
    final answer = find.byType(OutlinedButton).first;
    await tester.ensureVisible(answer);
    await tester.tap(answer);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('challengeNext')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('full chart rounds stop at ten and show grouped readings', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(ChallengeScreen(letters: mongolianLetters)));
    for (var i = 0; i < ChallengeScreen.roundLength; i++) {
      expect(find.text('Question ${i + 1} of 10'), findsOneWidget);
      final painter =
          tester
                  .widget<CustomPaint>(find.byKey(const Key('challengeGlyph')))
                  .painter!
              as MiniGlyphPainter;
      final accepted = recognitionAnswersFor(
        painter.character,
        mongolianLetters,
      );
      final answer = find.byKey(Key('answer_${painter.character.cyrillic}'));
      if (accepted.length > 1) {
        expect(
          find.text(
            'This shape has several readings. Choose the matching group.',
          ),
          findsOneWidget,
        );
        for (final reading in accepted) {
          expect(
            find.descendant(
              of: answer,
              matching: find.textContaining(reading.cyrillic),
            ),
            findsOneWidget,
          );
        }
      }
      await tester.ensureVisible(answer);
      await tester.tap(answer);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('challengeNext')));
      await tester.tap(find.byKey(const Key('challengeNext')));
      await tester.pumpAndSettle();
    }
    expect(find.text('10 of 10 correct'), findsOneWidget);
  });

  testWidgets('empty or single-letter collections do not start a quiz', (
    tester,
  ) async {
    for (final letters in [
      <dynamic>[],
      [letterNInitial, letterNMedial],
    ]) {
      await tester.pumpWidget(
        wrap(ChallengeScreen(key: UniqueKey(), letters: letters.cast())),
      );
      expect(
        find.text('More letters are needed to start a challenge.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
