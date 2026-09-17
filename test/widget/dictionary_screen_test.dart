import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/screens/home_path_screen.dart';
import 'package:learn_uigarjin/src/screens/lesson_screen.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );

  Future<void> openDictionary(WidgetTester tester) async {
    await tester.pumpWidget(wrap(HomePathScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dictionary'));
    await tester.pumpAndSettle();
  }

  testWidgets('dictionary groups every form of a letter under one entry', (
    tester,
  ) async {
    await openDictionary(tester);

    // N has a primary initial, medial and final form (plus a medial
    // alternate, which should collapse into the primary medial tile).
    expect(find.byKey(const Key('dictForm_n_initial')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_n_medial')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_n_final')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_n_medial_alternate')), findsNothing);

    // NG only has medial and final forms in the chart — no initial slot.
    expect(find.byKey(const Key('dictForm_ng_medial')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_ng_final')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_ng_initial')), findsNothing);
  });

  testWidgets('searching by Cyrillic filters down to the matching letter', (
    tester,
  ) async {
    await openDictionary(tester);

    await tester.enterText(
      find.byKey(const Key('dictionarySearchField')),
      'НГ',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dictForm_ng_medial')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_ng_final')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_n_initial')), findsNothing);
  });

  testWidgets('searching by Romaji filters down to the matching letter', (
    tester,
  ) async {
    await openDictionary(tester);

    await tester.enterText(
      find.byKey(const Key('dictionarySearchField')),
      'kh',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dictForm_kh_initial')), findsOneWidget);
    expect(find.byKey(const Key('dictForm_n_initial')), findsNothing);
  });

  testWidgets('a search with no matches shows an empty state', (
    tester,
  ) async {
    await openDictionary(tester);

    await tester.enterText(
      find.byKey(const Key('dictionarySearchField')),
      'zzz not a letter',
    );
    await tester.pumpAndSettle();

    expect(find.text('No letters match your search.'), findsOneWidget);
  });

  testWidgets('the clear button resets the search', (tester) async {
    await openDictionary(tester);

    await tester.enterText(
      find.byKey(const Key('dictionarySearchField')),
      'kh',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dictForm_n_initial')), findsNothing);

    await tester.tap(find.byKey(const Key('dictionaryClearSearchButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dictForm_n_initial')), findsOneWidget);
  });

  testWidgets('tapping a form opens the lesson for that exact shape', (
    tester,
  ) async {
    await openDictionary(tester);

    await tester.ensureVisible(find.byKey(const Key('dictForm_kh_initial')));
    await tester.tap(find.byKey(const Key('dictForm_kh_initial')));
    await tester.pumpAndSettle();

    expect(find.byType(LessonScreen), findsOneWidget);
    expect(
      tester.widget<LessonScreen>(find.byType(LessonScreen)).character.id,
      'kh_initial',
    );
  });
}
