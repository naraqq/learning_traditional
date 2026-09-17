// Visual review utility. Requires build/design/chart-before.json from before
// regeneration. Run: flutter test tool/glyph_smoothing_preview_test.dart
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/painters/mini_glyph_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('export enlarged before and after glyphs', () async {
    final loader = FontLoader('Roboto')..addFont(rootBundle.load('assets/fonts/Roboto-regular.ttf'));
    await loader.load();
    final before = jsonDecode(File('build/design/chart-before.json').readAsStringSync()) as List;
    const ids = ['n_initial', 'b_initial', 'g_initial', 'sh_final', 'a_initial', 'oeue_initial', 'l_final', 'p_initial', 'ng_final', 'r_initial', 'm_final', 'td_initial'];
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(const Color(0xFFF7F5EF), BlendMode.src);
    void label(String text, Offset at, {double size = 18}) {
      final painter = TextPainter(text: TextSpan(text: text, style: TextStyle(fontFamily: 'Roboto', fontSize: size, color: const Color(0xFF203B35))), textDirection: TextDirection.ltr)..layout();
      painter.paint(canvas, at);
    }
    for (var i = 0; i < ids.length; i++) {
      final origin = Offset((i % 3) * 400.0, (i ~/ 3) * 260.0);
      label(ids[i], origin + const Offset(16, 12));
      label('Before', origin + const Offset(55, 42), size: 14);
      label('After', origin + const Offset(255, 42), size: 14);
      final original = before.firstWhere((c) => c['id'] == ids[i]);
      final path = Path()..fillType = PathFillType.evenOdd;
      for (final contour in original['outlines'] as List) {
        path.addPolygon([for (final p in contour) Offset((p[0] as num) * 190, (p[1] as num) * 190)], true);
      }
      canvas.save();
      canvas.translate(origin.dx, origin.dy + 65);
      canvas.drawPath(path, Paint()..color = const Color(0xFF203B35));
      canvas.translate(200, 0);
      canvas.drawPath(chartOutlinePath(mongolianLetters.firstWhere((c) => c.id == ids[i]), const Size.square(190)), Paint()..color = const Color(0xFF203B35));
      canvas.restore();
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(1200, 1040);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('build/design/glyph-smoothing.png').writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
  });
}
