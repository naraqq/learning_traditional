/// Presentation-independent feedback; translated when the UI renders it.
/// Directional hints remain distinct so localization never loses useful detail.
enum LessonFeedback {
  traceFirst,
  alreadyComplete,
  undo,
  incomplete,
  incompleteToEnd,
  wrongDirection,
  lowSimilarity,
  correct,
  startLower,
  startHigher,
  startRight,
  startLeft,
}
