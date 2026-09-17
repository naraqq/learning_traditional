import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/models/character_definition.dart';
import 'package:learn_uigarjin/src/validation/stroke_validator.dart';

void main() {
  test('chart includes all 23 groups, 73 forms and no invented initial ng', () {
    expect(mongolianLetters.length, 73);
    expect(mongolianLetters.map((c) => c.id).toSet().length, 73);
    expect(mongolianLetters.map((c) => c.cyrillic).toSet().length, 23);
    expect(mongolianLetters.where((c) => c.alternate).length, 5);
    expect(mongolianLetters.where((c) => c.id == 'ng_initial'), isEmpty);
    // Lessons are grouped by letter (initial, medial, final, then any
    // alternates, contiguously) in the order this alphabet is taught:
    // vowels first, then consonants matching the reference chart.
    const expectedLetterOrder = [
      'a', 'e', 'i', 'ou', 'oeue', //
      'n', 'm', 'l', 'r', //
      'y', 'g', 'kh', 'b', 'td', //
      's', 'sh', 'jz', 'chts', //
      'p', 'f', 'k', 'v', 'ng',
    ];
    final letterOrder = <String>[];
    for (final letter in mongolianLetters) {
      final base = letter.id.split('_').first;
      if (letterOrder.isEmpty || letterOrder.last != base) {
        letterOrder.add(base);
      }
    }
    expect(letterOrder, expectedLetterOrder);
    for (final letter in mongolianLetters) {
      expect(letter.outlineContours, isNotEmpty, reason: letter.id);
      for (final point in [
        ...letter.outlineContours.expand((c) => c),
        ...letter.strokes.expand((s) => s.points),
      ]) {
        expect(point.dx, inInclusiveRange(0, 1), reason: letter.id);
        expect(point.dy, inInclusiveRange(0, 1), reason: letter.id);
      }
    }
  });

  test('every tracing segment including dots can pass the validator', () {
    const validator = StrokeValidator();
    for (final letter in mongolianLetters) {
      for (final stroke in letter.strokes) {
        final result = validator.validate(
          userPoints: stroke.points,
          reference: stroke,
          startZoneRadius: letter.startZoneRadius,
          endZoneRadius: letter.endZoneRadius,
          pathTolerance: letter.pathTolerance,
          mode: ToleranceMode.advanced,
        );
        expect(
          result.accepted,
          isTrue,
          reason: '${letter.id} segment ${stroke.order}: ${result.reason}',
        );
      }
    }
  });

  test('shared shapes have all valid readings without duplicate choices', () {
    CharacterDefinition letter(String id) =>
        mongolianLetters.firstWhere((c) => c.id == id);
    expect(
      recognitionAnswersFor(
        letter('a_medial'),
        mongolianLetters,
      ).map((c) => c.cyrillic).toSet(),
      {'А', 'Э', 'Н'},
    );
    expect(
      recognitionAnswersFor(
        letter('g_medial_alternate'),
        mongolianLetters,
      ).map((c) => c.cyrillic).toSet(),
      {'Г', 'Х'},
    );
    expect(
      recognitionAnswersFor(
        letter('ou_final'),
        mongolianLetters,
      ).map((c) => c.cyrillic).toSet(),
      {'О / У', 'Ө / Ү'},
    );
    expect(recognitionAnswersFor(letterNInitial, mongolianLetters).length, 1);
    expect(letterNInitial.strokes.length, 2); // the distinguishing dot survives
  });
}
