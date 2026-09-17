import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learn_uigarjin/main.dart';

import 'test_support.dart';

void main() {
  testWidgets('App launches into the letter path home screen', (
    WidgetTester tester,
  ) async {
    // The home path's next-up node pulses with a perpetually repeating
    // animation (skipped under reduced motion — see LetterPathNode).
    // Simulating reduced motion here lets pumpAndSettle() converge.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    // A store that has already been through first-run language selection,
    // so this smoke test lands straight on Home like it always has — the
    // splash/language-select flow itself is covered by its own test.
    await tester.pumpWidget(MongolianHandwritingApp(store: onboardedStore()));
    await tester.pumpAndSettle();

    expect(find.text('Mongolian Script'), findsOneWidget);
    expect(find.text('0/${mongolianLetters.length}'), findsOneWidget);
  });
}
