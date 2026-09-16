import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/l10n/localization.dart';
import 'package:learn_uigarjin/src/controllers/app_progress_controller.dart';
import 'package:learn_uigarjin/src/models/lesson_feedback.dart';
import 'package:learn_uigarjin/src/storage/progress_store.dart';

void main() {
  test(
    'both catalogs contain the same messages with no empty translations',
    () {
      Map<String, dynamic> catalog(String language) =>
          (jsonDecode(File('lib/l10n/app_$language.arb').readAsStringSync())
                as Map<String, dynamic>)
            ..removeWhere((key, _) => key.startsWith('@'));
      final en = catalog('en');
      final mn = catalog('mn');
      expect(mn.keys.toSet(), en.keys.toSet());
      for (final value in mn.values) {
        expect((value as String).trim(), isNotEmpty);
      }
    },
  );

  test(
    'every feedback state has distinct English and Mongolian messages',
    () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final mn = await AppLocalizations.delegate.load(const Locale('mn'));
      for (final feedback in LessonFeedback.values) {
        expect(
          mn.feedback(feedback),
          isNot(en.feedback(feedback)),
          reason: feedback.name,
        );
        expect(mn.feedback(feedback), isNotEmpty);
      }
      expect(en.unitSummary(1), '1 letter form · Guided handwriting');
      expect(en.unitSummary(6), '6 letter forms · Guided handwriting');
      expect(mn.unitSummary(6), '6 үсгийн хэлбэр · Загвар дагаж бичих');
    },
  );

  test(
    'language preference survives restart without changing progress',
    () async {
      final store = MemoryProgressStore();
      final first = AppProgressController(orderedIds: ['a', 'b'], store: store);
      await first.load();
      await first.markCompleted('a', score: 92);
      await first.updateSettings(languageCode: 'mn');
      first.dispose();
      final restored = AppProgressController(
        orderedIds: ['a', 'b'],
        store: store,
      );
      await restored.load();
      expect(restored.languageCode, 'mn');
      expect(restored.completedCount, 1);
      expect(restored.bestScore('a'), 92);
      expect(restored.isUnlocked('b'), isTrue);
      restored.dispose();
    },
  );

  test('older saves keep their progress and use the device language', () async {
    final store = MemoryProgressStore()
      ..value = jsonEncode({
        'version': 1,
        'completed': ['a'],
        'scores': {'a': 84},
        'practiceCount': 2,
        'settings': {'beginner': true, 'beautify': false, 'haptics': true},
      });
    final progress = AppProgressController(
      orderedIds: ['a', 'b'],
      store: store,
      initialLanguageCode: 'mn',
    );
    await progress.load();
    expect(progress.loadFailed, isFalse);
    expect(progress.languageCode, 'mn');
    expect(progress.isCompleted('a'), isTrue);
    expect(progress.beautify, isFalse);
    await progress.updateSettings(languageCode: 'en');
    final data = jsonDecode(store.value!) as Map<String, dynamic>;
    expect(data['settings']['languageCode'], 'en');
    expect(data['completed'], ['a']);
    progress.dispose();
  });

  test(
    'unsupported saved language falls back without blocking saved lessons',
    () async {
      final store = MemoryProgressStore()
        ..value = jsonEncode({
          'version': 1,
          'completed': ['a'],
          'scores': {},
          'practiceCount': 1,
          'settings': {
            'beginner': true,
            'beautify': true,
            'haptics': true,
            'languageCode': 'xx',
          },
        });
      final progress = AppProgressController(
        orderedIds: ['a', 'b'],
        store: store,
      );
      await progress.load();
      expect(progress.languageCode, 'en');
      expect(progress.loadFailed, isFalse);
      expect(progress.completedCount, 1);
      progress.dispose();
    },
  );
}
