import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/main.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';
import 'package:learn_uigarjin/src/widgets/writing_canvas.dart';

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1024, 768),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('navigation and writing fit $size with text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MongolianHandwritingApp(store: MemoryProgressStore()),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final tab in ['Learn', 'Review', 'Settings', 'Home']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: tab);
        }
        await tester.ensureVisible(
          find.byKey(const Key('continueLearningButton')),
        );
        await tester.tap(find.byKey(const Key('continueLearningButton')));
        await tester.pumpAndSettle();
        expect(find.byType(WritingCanvas), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'lesson');
        await tester.ensureVisible(find.byKey(const Key('continueButton')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('settings persist when the app is recreated', (tester) async {
    final store = MemoryProgressStore();
    await tester.pumpWidget(MongolianHandwritingApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beginner guidance'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(MongolianHandwritingApp(store: store));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Beginner guidance'),
    );
    expect(tile.value, isFalse);
  });
}
