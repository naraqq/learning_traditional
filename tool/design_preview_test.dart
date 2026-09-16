// Export actual Flutter screens, with real fonts, for visual review.
// flutter test tool/design_preview_test.dart --dart-define=FLUTTER_SDK=/path/to/flutter
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/main.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';
import 'package:learn_uigarjin/src/widgets/writing_canvas.dart';

void main() {
  testWidgets('export design previews', (tester) async {
    const sdk = String.fromEnvironment('FLUTTER_SDK');
    expect(
      sdk,
      isNotEmpty,
      reason: 'Pass --dart-define=FLUTTER_SDK=/path/to/flutter',
    );
    await tester.runAsync(() async {
      final fonts = FontLoader('Roboto');
      for (final name in ['regular', 'medium', 'bold']) {
        fonts.addFont(
          File(
            '$sdk/bin/cache/artifacts/material_fonts/Roboto-$name.ttf',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await fonts.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        File(
          '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await icons.load();
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MongolianHandwritingApp(store: MemoryProgressStore()),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('build/design/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('home');
    for (final tab in ['Learn', 'Review', 'Settings']) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      await capture(tab.toLowerCase());
    }
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('continueLearningButton')));
    await tester.tap(find.byKey(const Key('continueLearningButton')));
    await tester.pumpAndSettle();
    await capture('lesson');
    final rect = tester.getRect(find.byType(WritingCanvas));
    Offset point(Offset p) =>
        Offset(rect.left + p.dx * rect.width, rect.top + p.dy * rect.height);
    final reference = letterNInitial.strokes.single.points;
    final gesture = await tester.startGesture(point(reference.first));
    for (final p in reference.skip(1)) {
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.moveTo(point(p));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('continueButton')));
    await tester.tap(find.byKey(const Key('continueButton')));
    await tester.pumpAndSettle();
    expect(find.text('Well done!'), findsOneWidget);
    await capture('results');
    await tester.ensureVisible(
      find.byKey(const Key('celebrationContinueButton')),
    );
    await tester.tap(find.byKey(const Key('celebrationContinueButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    await capture('review-completed');
    expect(tester.takeException(), isNull);
  });
}
