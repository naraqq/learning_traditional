import 'package:flutter_test/flutter_test.dart';
import 'package:learn_uigarjin/src/controllers/lesson_controller.dart';
import 'package:learn_uigarjin/src/data/mongolian_letters.dart';
import 'package:learn_uigarjin/src/validation/stroke_validator.dart';

void main() {
  test('disabling polish keeps accepted ink unchanged during animation', () {
    final lesson = LessonController(
      character: letterNInitial,
      beautifyEnabled: false,
      toleranceMode: ToleranceMode.advanced,
    );
    final result = lesson.submitStroke(letterNInitial.strokes.first.points);
    expect(result.accepted, isTrue);
    expect(lesson.toleranceMode, ToleranceMode.advanced);
    final stroke = lesson.completedStrokes.single;
    expect(stroke.beautifiedPoints, orderedEquals(stroke.rawPoints));
    lesson.updateBeautifyProgress(1);
    expect(stroke.displayPoints, orderedEquals(stroke.rawPoints));
    lesson.dispose();
  });
}
