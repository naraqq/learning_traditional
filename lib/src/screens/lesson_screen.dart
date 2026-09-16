import 'package:flutter/material.dart';
import '../controllers/lesson_controller.dart';
import '../models/character_definition.dart';
import '../painters/mini_glyph_painter.dart';
import '../theme/app_theme.dart';
import '../validation/stroke_validator.dart';
import '../widgets/feedback_banner.dart';
import '../widgets/icon_chip_button.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/primary_action_button.dart';
import '../widgets/tolerance_toggle.dart';
import '../widgets/writing_canvas.dart';

String _formLabel(CharacterForm form) => switch (form) {
  CharacterForm.isolated => 'Isolated form',
  CharacterForm.initial => 'Initial form',
  CharacterForm.medial => 'Medial form',
  CharacterForm.final_ => 'Final form',
};

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.character,
    this.toleranceMode = ToleranceMode.beginner,
    this.beautify = true,
    this.haptics = true,
    this.onCompleted,
  });
  final CharacterDefinition character;
  final ToleranceMode toleranceMode;
  final bool beautify;
  final bool haptics;
  final ValueChanged<double>? onCompleted;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final LessonController _controller;
  final GlobalKey<WritingCanvasState> _canvasKey =
      GlobalKey<WritingCanvasState>();
  bool _showCelebration = false;
  final Set<int> _drawingPointers = {};

  @override
  void initState() {
    super.initState();
    _controller = LessonController(
      character: widget.character,
      toleranceMode: widget.toleranceMode,
      beautifyEnabled: widget.beautify,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    bottomNavigationBar: _showCelebration
        ? null
        : SafeArea(
            top: false,
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (_, _) => PrimaryActionButton(
                      key: const Key('continueButton'),
                      label: 'Continue',
                      onPressed: _controller.isComplete
                          ? () {
                              widget.onCompleted?.call(
                                _controller.averageScore,
                              );
                              setState(() => _showCelebration = true);
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: _showCelebration
              ? _results()
              : LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    physics: _drawingPointers.isNotEmpty
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              key: const Key('lessonCloseButton'),
                              tooltip: 'Back to learning',
                              onPressed: () =>
                                  Navigator.of(context).maybePop(false),
                              icon: const Icon(Icons.close_rounded),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (_, _) => LessonProgressBar(
                                  progress: _controller.progress,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, _) => Text(
                                '${_controller.currentStrokeIndex}/${widget.character.strokes.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'HANDWRITING PRACTICE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.6,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.character.cyrillic} · ${widget.character.transliteration} — ${_formLabel(widget.character.form)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (_, _) => ToleranceToggle(
                              mode: _controller.toleranceMode,
                              onChanged: _controller.setToleranceMode,
                            ),
                          ),
                        ),
                        if (widget.character.isDemoData) ...[
                          const SizedBox(height: 10),
                          const Text(
                            'Preview letter · Shape and stroke order pending expert review.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.secondaryDark,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Listener(
                          onPointerDown: (event) => setState(
                            () => _drawingPointers.add(event.pointer),
                          ),
                          onPointerUp: (event) => setState(
                            () => _drawingPointers.remove(event.pointer),
                          ),
                          onPointerCancel: (event) => setState(
                            () => _drawingPointers.remove(event.pointer),
                          ),
                          child: Container(
                            height: (constraints.maxHeight - 365).clamp(
                              220.0,
                              560.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.line),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Semantics(
                              label:
                                  'Writing area. Trace the reference from its marked start point.',
                              child: WritingCanvas(
                                key: _canvasKey,
                                controller: _controller,
                                haptics: widget.haptics,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, _) => IconChipButton(
                                key: const Key('undoButton'),
                                icon: Icons.undo_rounded,
                                label: 'Undo',
                                onPressed: _controller.completedStrokes.isEmpty
                                    ? null
                                    : _controller.undoLastStroke,
                              ),
                            ),
                            IconChipButton(
                              key: const Key('clearButton'),
                              icon: Icons.refresh_rounded,
                              label: 'Clear',
                              onPressed: _controller.clearAll,
                            ),
                            IconChipButton(
                              key: const Key('showAgainButton'),
                              icon: Icons.play_circle_outline_rounded,
                              label: 'Show again',
                              onPressed: () =>
                                  _canvasKey.currentState?.playDemo(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (_, _) => Semantics(
                            liveRegion: true,
                            child: FeedbackBanner(
                              message: _controller.feedbackMessage,
                              tone: _controller.lastAccepted == null
                                  ? FeedbackTone.neutral
                                  : _controller.lastAccepted!
                                  ? FeedbackTone.success
                                  : FeedbackTone.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    ),
  );

  Widget _results() => SingleChildScrollView(
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ONE STEP FURTHER',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 2,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Container(
            width: 132,
            height: 174,
            padding: const EdgeInsets.fromLTRB(38, 24, 38, 24),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEEDF),
              borderRadius: BorderRadius.circular(66),
            ),
            child: CustomPaint(
              painter: MiniGlyphPainter(
                character: widget.character,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Well done!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          '${widget.character.cyrillic} · ${widget.character.transliteration} complete',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Every stroke is a little more familiar.\nKeep showing up for your practice.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            children: [
              Text(
                '${_controller.averageScore.round()}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Text('Tracing score'),
              const SizedBox(height: 8),
              Text(
                _controller.toleranceMode == ToleranceMode.beginner
                    ? 'Beginner guidance'
                    : 'Advanced guidance',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryActionButton(
          key: const Key('celebrationContinueButton'),
          label: 'Back to learning',
          icon: Icons.check_rounded,
          onPressed: _finish,
        ),
      ],
    ),
  );
}
