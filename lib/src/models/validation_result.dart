/// Why a stroke was accepted or rejected, used to pick short feedback text
/// and to decide whether beautification should run.
enum StrokeFeedbackReason {
  correct,
  startTooFar,
  wrongDirection,
  incomplete,
  lowSimilarity,
}

/// Result of validating one learner stroke against its expected reference
/// stroke. All scores are 0-100, higher is better.
class StrokeValidationResult {
  const StrokeValidationResult({
    required this.overallScore,
    required this.startScore,
    required this.endScore,
    required this.directionScore,
    required this.similarityScore,
    required this.coverageScore,
    required this.accepted,
    required this.reason,
    required this.message,
  });

  final double overallScore;
  final double startScore;
  final double endScore;
  final double directionScore;
  final double similarityScore;
  final double coverageScore;

  final bool accepted;
  final StrokeFeedbackReason reason;

  /// Short, learner-facing feedback, e.g. "Correct!" or "Wrong direction".
  final String message;
}
