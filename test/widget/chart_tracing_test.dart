import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/screens/lesson_screen.dart';
import 'package:learn_uigarjin/src/widgets/writing_canvas.dart';
import '../test_support.dart';

void main() {
  testWidgets('all chart forms can be completed through pointer input', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    for (final letter in mongolianLetters) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LessonScreen(key: ValueKey(letter.id), character: letter),
        ),
      );
      await tester.pumpAndSettle();
      await traceLetter(tester, letter);
      expect(
        tester
            .widget<WritingCanvas>(find.byType(WritingCanvas))
            .controller
            .isComplete,
        isTrue,
        reason: letter.id,
      );
      expect(tester.takeException(), isNull, reason: letter.id);
    }
  });
}
