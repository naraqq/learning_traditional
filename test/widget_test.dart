import 'package:flutter_test/flutter_test.dart';

import 'package:learn_uigarjin/main.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';

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

    await tester.pumpWidget(
      MongolianHandwritingApp(store: MemoryProgressStore()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mongolian Script'), findsOneWidget);
    expect(find.text('0/6'), findsOneWidget);
  });
}
