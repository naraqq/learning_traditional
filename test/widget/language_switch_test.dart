import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/main.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';

import '../test_support.dart';

void main() {
  testWidgets(
    'language changes immediately, survives restart, and switches back',
    (tester) async {
      final store = onboardedStore();
      await tester.pumpWidget(MongolianHandwritingApp(store: store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('languageSelector')));
      await tester.tap(find.byKey(const Key('languageSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Монгол').last);
      await tester.pumpAndSettle();
      expect(find.text('Тохиргоо'), findsOneWidget);
      expect(find.text('Өөртөө тохируулж сураарай.'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
        const Locale('mn'),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MongolianHandwritingApp(store: store));
      await tester.pumpAndSettle();
      expect(find.text('Нүүр'), findsOneWidget);
      await tester.tap(find.text('Тохиргоо'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('languageSelector')));
      await tester.tap(find.byKey(const Key('languageSelector')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English').last);
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Practice, your way.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Mongolian device language covers locked lessons, feedback, results and review',
    (tester) async {
      tester.platformDispatcher.localesTestValue = [const Locale('mn', 'MN')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pumpWidget(
        MongolianHandwritingApp(store: onboardedStore(languageCode: 'mn')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Нүүр'), findsOneWidget);
      await tester.tap(find.text('Сурах'));
      await tester.pumpAndSettle();
      final second = find.byKey(Key('node_${mongolianLetters[1].id}'));
      await tester.ensureVisible(second);
      await tester.tap(second);
      await tester.pumpAndSettle();
      expect(
        find.text('Эхлээд өмнөх үсгийн хичээлийг дуусгаарай.'),
        findsOneWidget,
      );
      final first = find.byKey(Key('node_${mongolianLetters[0].id}'));
      await tester.ensureVisible(first);
      await tester.tap(first);
      await tester.pumpAndSettle();
      expect(find.text('БИЧИХ ДАСГАЛ'), findsOneWidget);
      expect(find.text('Эхний зураасыг дагуулж бичээрэй.'), findsOneWidget);
      await traceLetter(tester, letterNInitial);
      expect(find.text('Зөв байна!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('continueButton')));
      await tester.pumpAndSettle();
      expect(find.text('Сайн байна!'), findsOneWidget);
      expect(find.text('Дагуулж бичсэн үнэлгээ'), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const Key('celebrationContinueButton')),
      );
      await tester.tap(find.byKey(const Key('celebrationContinueButton')));
      await tester.pumpAndSettle();
      expect(find.text('1/${mongolianLetters.length}'), findsOneWidget);
      await tester.tap(find.text('Давтах'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Дээд үнэлгээ:'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('unsupported device language uses English', (tester) async {
    tester.platformDispatcher.localesTestValue = [const Locale('fr')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    await tester.pumpWidget(MongolianHandwritingApp(store: onboardedStore()));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      const Locale('en'),
    );
  });
}
