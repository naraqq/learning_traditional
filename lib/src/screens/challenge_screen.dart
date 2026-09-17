import 'dart:math';

import 'package:flutter/material.dart';

import '../../l10n/localization.dart';
import '../models/character_definition.dart';
import '../data/mongolian_letters.dart';
import '../painters/mini_glyph_painter.dart';
import '../theme/app_theme.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.letters});

  final List<CharacterDefinition> letters;
  static const roundLength = 10;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  final _random = Random();
  final _scrollController = ScrollController();
  late List<CharacterDefinition> _questions;
  List<CharacterDefinition> _options = [];
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _finished = false;

  bool get _available =>
      widget.letters.map((c) => c.cyrillic).toSet().length >= 2;
  CharacterDefinition get _question => _questions[_index];

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _restart() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _questions = ([
      ...widget.letters,
    ]..shuffle(_random)).take(ChallengeScreen.roundLength).toList();
    _index = 0;
    _score = 0;
    _selected = null;
    _finished = false;
    if (_available) _prepareOptions();
  }

  List<CharacterDefinition> get _accepted =>
      recognitionAnswersFor(_question, widget.letters);
  String _answerLabel(CharacterDefinition option) {
    final matches = option == _question ? _accepted : [option];
    return '${matches.map((c) => c.cyrillic).join(' / ')} · ${matches.map((c) => c.transliteration).join(' / ')}';
  }

  void _prepareOptions() {
    // Different positional forms of one letter must not create duplicate answers.
    final unique = {for (final c in widget.letters) c.cyrillic: c};
    for (final answer in _accepted) {
      unique.remove(answer.cyrillic);
    }
    final distractors = unique.values.toList()..shuffle(_random);
    _options = [_question, ...distractors.take(3)]..shuffle(_random);
  }

  void _answer(String letter) {
    if (_selected != null) return;
    setState(() {
      _selected = letter;
      if (letter == _question.cyrillic) _score++;
    });
  }

  void _next() => setState(() {
    _scrollController.jumpTo(0);
    if (_index == _questions.length - 1) {
      _finished = true;
    } else {
      _index++;
      _selected = null;
      _prepareOptions();
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.challengeTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: !_available
                  ? Text(l10n.challengeUnavailable)
                  : _finished
                  ? _results(context)
                  : _quiz(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quiz(BuildContext context) {
    final l10n = context.l10n;
    final answered = _selected != null;
    final correct = _selected == _question.cyrillic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.challengeQuestion(_index + 1, _questions.length)),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: (_index + (answered ? 1 : 0)) / _questions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(8),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.challengePrompt,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(l10n.characterForm(_question)),
        if (_accepted.length > 1) ...[
          const SizedBox(height: 8),
          Text(l10n.challengeShared),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
          ),
          child: Semantics(
            label: l10n.challengeGlyph,
            image: true,
            child: Center(
              child: SizedBox(
                width: 180,
                height: 190,
                child: CustomPaint(
                  key: const Key('challengeGlyph'),
                  painter: MiniGlyphPainter(
                    character: _question,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final option in _options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              key: Key('answer_${option.cyrillic}'),
              onPressed: answered ? null : () => _answer(option.cyrillic),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(48, 54),
                disabledForegroundColor: AppColors.ink,
                backgroundColor:
                    answered && option.cyrillic == _question.cyrillic
                    ? AppColors.success.withValues(alpha: 0.13)
                    : answered && option.cyrillic == _selected
                    ? AppColors.error.withValues(alpha: 0.10)
                    : AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _answerLabel(option),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (answered && option.cyrillic == _question.cyrillic)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                    )
                  else if (answered && option.cyrillic == _selected)
                    const Icon(Icons.cancel_rounded, color: AppColors.error),
                ],
              ),
            ),
          ),
        if (answered) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: Text(
              correct
                  ? l10n.challengeCorrect
                  : '${l10n.challengeIncorrect} ${l10n.challengeAnswer(_accepted.map((c) => c.cyrillic).join(' / '))}',
              style: TextStyle(
                color: correct ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('challengeNext'),
            onPressed: _next,
            child: Text(
              _index == _questions.length - 1
                  ? l10n.challengeResults
                  : l10n.challengeNext,
            ),
          ),
        ],
      ],
    );
  }

  Widget _results(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 32),
        const Icon(
          Icons.emoji_events_rounded,
          size: 80,
          color: AppColors.secondaryDark,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.challengeComplete,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.challengeScore(_score, _questions.length),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          key: const Key('challengeAgain'),
          onPressed: () => setState(_restart),
          icon: const Icon(Icons.replay_rounded),
          label: Text(l10n.challengeAgain),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.challengeHome),
        ),
      ],
    );
  }
}
