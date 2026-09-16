import 'package:flutter/widgets.dart';
import '../src/models/character_definition.dart';
import '../src/models/lesson_feedback.dart';
import 'generated/app_localizations.dart';
export 'generated/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension LearningMessages on AppLocalizations {
  String form(CharacterForm value) => switch (value) {
    CharacterForm.isolated => isolatedForm,
    CharacterForm.initial => initialForm,
    CharacterForm.medial => medialForm,
    CharacterForm.final_ => finalForm,
  };

  String feedback(LessonFeedback value) => switch (value) {
    LessonFeedback.traceFirst => feedbackTraceFirst,
    LessonFeedback.alreadyComplete => feedbackAlreadyComplete,
    LessonFeedback.undo => feedbackUndo,
    LessonFeedback.incomplete => feedbackIncomplete,
    LessonFeedback.incompleteToEnd => feedbackIncompleteToEnd,
    LessonFeedback.wrongDirection => feedbackWrongDirection,
    LessonFeedback.lowSimilarity => feedbackLowSimilarity,
    LessonFeedback.correct => feedbackCorrect,
    LessonFeedback.startLower => feedbackStartLower,
    LessonFeedback.startHigher => feedbackStartHigher,
    LessonFeedback.startRight => feedbackStartRight,
    LessonFeedback.startLeft => feedbackStartLeft,
  };
}
