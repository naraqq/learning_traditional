import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/active_stroke_controller.dart';
import '../controllers/lesson_controller.dart';
import '../geometry/geometry_utils.dart';
import '../geometry/smoothing.dart';
import '../painters/active_stroke_painter.dart';
import '../painters/completed_strokes_painter.dart';
import '../painters/reference_guide_painter.dart';
import '../painters/rejected_flash_painter.dart';
import '../painters/stroke_demo_painter.dart';
import '../painters/writing_sheet_painter.dart';

/// The large vertical writing sheet: reference guide, animated stroke
/// demonstration, previously completed ink, and the stroke currently being
/// drawn — all layered inside one [RepaintBoundary] so drawing stays smooth
/// without rebuilding the rest of the lesson screen.
///
/// Pointer handling is done with a low-level [Listener] so it works
/// uniformly for finger and stylus input (including pressure, when the
/// platform reports it) on both Android and iOS.
class WritingCanvas extends StatefulWidget {
  const WritingCanvas({
    super.key,
    required this.controller,
    this.haptics = true,
  });

  final bool haptics;

  final LessonController controller;

  @override
  State<WritingCanvas> createState() => WritingCanvasState();
}

class WritingCanvasState extends State<WritingCanvas>
    with TickerProviderStateMixin {
  final ActiveStrokeController _activeStroke = ActiveStrokeController();
  final OneEuroLikeFilter _liveFilter = OneEuroLikeFilter(
    minCutoff: 1.2,
    beta: 0.4,
  );

  late final AnimationController _beautifyAnim;
  late final AnimationController _glowAnim;
  late final AnimationController _rejectFadeAnim;
  late final AnimationController _demoAnim;

  Size _canvasSize = Size.zero;
  Offset? _lastRawPoint;
  int? _activePointerId;
  bool _reduceMotion = false;
  int _demoStrokeIndex = 0;

  @override
  void initState() {
    super.initState();
    _beautifyAnim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        )..addListener(
          () => widget.controller.updateBeautifyProgress(_beautifyAnim.value),
        );
    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() => setState(() {}));
    _rejectFadeAnim =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 700),
          )
          ..addListener(() => setState(() {}))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              widget.controller.dismissRejectedFlash();
            }
          });
    _demoAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..addListener(() => setState(() {}));
    widget.controller.addListener(_onLessonChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) playDemo();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  void _onLessonChanged() {
    // Replay the demo automatically whenever the expected stroke changes.
    final index = widget.controller.currentStrokeIndex;
    if (index != _demoStrokeIndex) {
      _demoStrokeIndex = index;
      _beautifyAnim.stop();
      if (mounted) playDemo();
    }
  }

  /// Plays (or replays) the stroke-order demonstration for the currently
  /// expected stroke. Exposed so the "Show again" button can trigger it.
  void playDemo() {
    if (widget.controller.currentReferenceStroke == null) {
      _demoAnim.stop();
      return;
    }
    if (_reduceMotion) {
      _demoAnim.value = 1;
      return;
    }
    _demoAnim.forward(from: 0);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onLessonChanged);
    _beautifyAnim.dispose();
    _glowAnim.dispose();
    _rejectFadeAnim.dispose();
    _demoAnim.dispose();
    _activeStroke.dispose();
    super.dispose();
  }

  Offset _normalize(Offset localPosition) {
    if (_canvasSize.width == 0 || _canvasSize.height == 0) return Offset.zero;
    return GeometryUtils.clampUnit(
      Offset(
        localPosition.dx / _canvasSize.width,
        localPosition.dy / _canvasSize.height,
      ),
    );
  }

  /// Normalizes a raw pointer pressure reading to 0.0-1.0, with 0.5 as the
  /// neutral fallback for devices (most finger touchscreens) that don't
  /// report real pressure — i.e. `pressureMin == pressureMax`.
  double _normalizedPressure(PointerEvent event) {
    if (event.pressureMax <= event.pressureMin) return 0.5;
    final range = event.pressureMax - event.pressureMin;
    return ((event.pressure - event.pressureMin) / range).clamp(0.0, 1.0);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.controller.isComplete) return;
    if (_activePointerId != null) return; // ignore secondary touches mid-stroke
    _activePointerId = event.pointer;
    _liveFilter.reset();
    final normalized = _normalize(event.localPosition);
    _lastRawPoint = normalized;
    _activeStroke.start(normalized, _normalizedPressure(event));
    _rejectFadeAnim.stop();
    widget.controller.dismissRejectedFlash();
  }

  static const double _minSampleDistance = 0.004;

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer != _activePointerId) return;
    final raw = _normalize(event.localPosition);
    final last = _lastRawPoint;
    if (last != null &&
        !GeometryUtils.isFarEnough(last, raw, _minSampleDistance)) {
      return; // too close to the previous sample — skip to avoid oversampling
    }
    _lastRawPoint = raw;
    final timestampMs = event.timeStamp.inMilliseconds;
    final smoothed = _liveFilter.filter(raw, timestampMs);
    _activeStroke.addPoint(smoothed, _normalizedPressure(event));
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer != _activePointerId) return;
    _activePointerId = null;
    _finishStroke();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activePointerId) return;
    _activePointerId = null;
    _activeStroke.clear();
  }

  void _finishStroke() {
    final raw = _activeStroke.takeSnapshot();
    final widthScale = _activeStroke.widthScale;
    _activeStroke.clear();
    if (raw.length < 2) return;

    final smoothed = StrokeSmoothing.movingAverage(raw, windowSize: 5);
    final result = widget.controller.submitStroke(
      smoothed,
      widthScale: widthScale,
    );

    if (result.accepted) {
      if (widget.haptics) HapticFeedback.lightImpact();
      if (_reduceMotion) {
        widget.controller.updateBeautifyProgress(1);
      } else {
        _beautifyAnim.forward(from: 0);
      }
      _glowAnim.forward(from: 0).whenComplete(() {
        if (mounted) _glowAnim.reset();
      });
    } else {
      if (widget.haptics) HapticFeedback.mediumImpact();
      if (_reduceMotion) {
        widget.controller.dismissRejectedFlash();
      } else {
        _rejectFadeAnim.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final character = controller.character;
        final rejectedPoints = controller.lastRejectedPoints;
        final rejectOpacity = rejectedPoints == null
            ? 0.0
            : (1 - Curves.easeIn.transform(_rejectFadeAnim.value)).clamp(
                0.0,
                1.0,
              );
        final glowOpacity = (1 - _glowAnim.value).clamp(0.0, 1.0);

        return RepaintBoundary(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _canvasSize = constraints.biggest;
              return Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: _onPointerDown,
                onPointerMove: _onPointerMove,
                onPointerUp: _onPointerUp,
                onPointerCancel: _onPointerCancel,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: WritingSheetPainter(character: character),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: ReferenceGuidePainter(
                          character: character,
                          currentStrokeIndex: controller.currentStrokeIndex,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: CompletedStrokesPainter(
                          strokes: controller.completedStrokes,
                          brushWidth: character.recommendedBrushWidth,
                          glowOpacity: glowOpacity,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: StrokeDemoPainter(
                          stroke: controller.currentReferenceStroke,
                          progress: _demoAnim.value,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: RejectedFlashPainter(
                          points: rejectedPoints,
                          opacity: rejectOpacity,
                          brushWidth: character.recommendedBrushWidth,
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: CustomPaint(
                        painter: ActiveStrokePainter(
                          _activeStroke,
                          brushWidth: character.recommendedBrushWidth,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
