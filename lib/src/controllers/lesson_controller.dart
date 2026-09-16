import '../models/lesson_feedback.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../beautify/stroke_beautifier.dart';
import '../geometry/geometry_utils.dart';
import '../models/character_definition.dart';
import '../models/completed_stroke.dart';
import '../models/reference_stroke.dart';
import '../models/validation_result.dart';
import '../validation/stroke_validator.dart';

/// Owns the state of one handwriting exercise: which stroke is expected
/// next, the strokes completed so far, feedback text, and tolerance mode.
///
/// This is UI-independent (a plain [ChangeNotifier]) so it can be driven
/// from widget tests or swapped screens without touching validation or
/// beautification logic.
class LessonController extends ChangeNotifier {
  LessonController({
    required CharacterDefinition character,
    ToleranceMode toleranceMode = ToleranceMode.beginner,
    this.beautifyEnabled = true,
    StrokeValidator validator = const StrokeValidator(),
    StrokeBeautifier beautifier = const StrokeBeautifier(),
  }) : _character = character,
       _toleranceMode = toleranceMode,
       _validator = validator,
       _beautifier = beautifier;

  CharacterDefinition _character;
  ToleranceMode _toleranceMode;
  final StrokeValidator _validator;
  final StrokeBeautifier _beautifier;
  final bool beautifyEnabled;

  final List<CompletedStroke> _completedStrokes = [];
  int _currentStrokeIndex = 0;
  LessonFeedback _feedback = LessonFeedback.traceFirst;

  /// Null until the first stroke attempt; then true/false for the most
  /// recent attempt's outcome. Used by the UI to pick feedback styling.
  bool? _lastAccepted;
  List<Offset>? _lastRejectedPoints;
  int _rejectedFlashToken = 0;

  CharacterDefinition get character => _character;
  ToleranceMode get toleranceMode => _toleranceMode;
  List<CompletedStroke> get completedStrokes =>
      List.unmodifiable(_completedStrokes);
  int get currentStrokeIndex => _currentStrokeIndex;

  ReferenceStroke? get currentReferenceStroke =>
      _currentStrokeIndex < _character.strokes.length
      ? _character.strokes[_currentStrokeIndex]
      : null;

  LessonFeedback get feedback => _feedback;
  bool? get lastAccepted => _lastAccepted;
  bool get isComplete => _currentStrokeIndex >= _character.strokes.length;
  double get progress => _character.strokes.isEmpty
      ? 0
      : _currentStrokeIndex / _character.strokes.length;
  List<Offset>? get lastRejectedPoints => _lastRejectedPoints;
  int get rejectedFlashToken => _rejectedFlashToken;

  /// Mean stroke score (0-100) across all completed strokes, used to derive
  /// a star rating once the exercise is finished. 100 when nothing has been
  /// drawn yet.
  double get averageScore {
    if (_completedStrokes.isEmpty) return 100;
    final total = _completedStrokes.fold<double>(0, (sum, s) => sum + s.score);
    return total / _completedStrokes.length;
  }

  void setToleranceMode(ToleranceMode mode) {
    if (_toleranceMode == mode) return;
    _toleranceMode = mode;
    notifyListeners();
  }

  /// Loads a new character/exercise, resetting all progress.
  void loadCharacter(CharacterDefinition character) {
    _character = character;
    _completedStrokes.clear();
    _currentStrokeIndex = 0;
    _feedback = LessonFeedback.traceFirst;
    _lastRejectedPoints = null;
    _lastAccepted = null;
    notifyListeners();
  }

  /// Validates a finished, lightly-smoothed raw stroke against the current
  /// expected reference stroke. On acceptance the stroke is appended to
  /// [completedStrokes] (with a freshly computed beautified version) and
  /// the lesson advances; on rejection the raw points are kept briefly in
  /// [lastRejectedPoints] for a visual flash.
  StrokeValidationResult submitStroke(
    List<Offset> rawPoints, {
    double widthScale = 1.0,
  }) {
    final reference = currentReferenceStroke;
    if (reference == null) {
      const result = StrokeValidationResult(
        overallScore: 0,
        startScore: 0,
        endScore: 0,
        directionScore: 0,
        similarityScore: 0,
        coverageScore: 0,
        accepted: false,
        reason: StrokeFeedbackReason.incomplete,
        feedback: LessonFeedback.alreadyComplete,
      );
      _feedback = result.feedback;
      notifyListeners();
      return result;
    }

    final result = _validator.validate(
      userPoints: rawPoints,
      reference: reference,
      startZoneRadius: reference.startZoneRadius ?? _character.startZoneRadius,
      endZoneRadius: reference.endZoneRadius ?? _character.endZoneRadius,
      pathTolerance: _character.pathTolerance,
      mode: _toleranceMode,
    );

    _feedback = result.feedback;
    _lastAccepted = result.accepted;

    if (result.accepted) {
      final userResampled = GeometryUtils.resample(
        rawPoints,
        StrokeBeautifier.pointCount,
      );
      final beautified = beautifyEnabled
          ? _beautifier.beautify(
              userPoints: rawPoints,
              referencePoints: reference.points,
              similarityScore: result.similarityScore,
            )
          : userResampled;
      _completedStrokes.add(
        CompletedStroke(
          strokeOrder: reference.order,
          rawPoints: userResampled,
          beautifiedPoints: beautified,
          accepted: true,
          widthScale: widthScale,
          score: result.overallScore,
        ),
      );
      _currentStrokeIndex++;
      _lastRejectedPoints = null;
    } else {
      _lastRejectedPoints = rawPoints;
      _rejectedFlashToken++;
    }
    notifyListeners();
    return result;
  }

  /// Updates the display interpolation for the most recently accepted
  /// stroke. Called every animation tick by the UI while it plays the
  /// ~200ms beautification transition. [t] is 0..1.
  void updateBeautifyProgress(double t) {
    if (_completedStrokes.isEmpty) return;
    final stroke = _completedStrokes.last;
    if (!stroke.accepted) return;
    final clamped = t.clamp(0.0, 1.0);
    stroke.displayPoints = [
      for (var i = 0; i < stroke.rawPoints.length; i++)
        Offset.lerp(stroke.rawPoints[i], stroke.beautifiedPoints[i], clamped)!,
    ];
    notifyListeners();
  }

  void undoLastStroke() {
    if (_completedStrokes.isEmpty) return;
    _completedStrokes.removeLast();
    _currentStrokeIndex = _completedStrokes.length;
    _feedback = LessonFeedback.undo;
    _lastRejectedPoints = null;
    _lastAccepted = null;
    notifyListeners();
  }

  void clearAll() {
    if (_completedStrokes.isEmpty && _lastRejectedPoints == null) return;
    _completedStrokes.clear();
    _currentStrokeIndex = 0;
    _feedback = LessonFeedback.traceFirst;
    _lastRejectedPoints = null;
    _lastAccepted = null;
    notifyListeners();
  }

  /// Called by the UI once the rejected-stroke flash animation finishes.
  void dismissRejectedFlash() {
    if (_lastRejectedPoints == null) return;
    _lastRejectedPoints = null;
    notifyListeners();
  }
}
