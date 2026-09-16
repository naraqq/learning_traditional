import '../../l10n/localization.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/app_progress_controller.dart';
import '../data/mongolian_letters.dart';
import '../models/character_definition.dart';
import '../validation/stroke_validator.dart';
import '../painters/mini_glyph_painter.dart';
import '../storage/progress_store.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_action_button.dart';
import 'lesson_screen.dart';

class HomePathScreen extends StatefulWidget {
  HomePathScreen({
    super.key,
    List<CharacterDefinition>? letters,
    this.store,
    this.progress,
  }) : letters = letters ?? mongolianLetters;
  final List<CharacterDefinition> letters;
  final ProgressStore? store;
  final AppProgressController? progress;

  @override
  State<HomePathScreen> createState() => _HomePathScreenState();
}

class _HomePathScreenState extends State<HomePathScreen> {
  late final AppProgressController _progress;
  int _tab = 0;
  AppLocalizations get _l10n => context.l10n;

  @override
  void initState() {
    super.initState();
    _progress =
        widget.progress ??
        AppProgressController(
          orderedIds: [for (final c in widget.letters) c.id],
          store: widget.store,
        );
    if (widget.progress == null) unawaited(_progress.load());
  }

  @override
  void dispose() {
    if (widget.progress == null) _progress.dispose();
    super.dispose();
  }

  Future<void> _openLesson(CharacterDefinition character) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          character: character,
          toleranceMode: _progress.beginner
              ? ToleranceMode.beginner
              : ToleranceMode.advanced,
          beautify: _progress.beautify,
          haptics: _progress.haptics,
          onCompleted: (score) {
            if (mounted) {
              unawaited(_progress.markCompleted(character.id, score: score));
            }
          },
        ),
      ),
    );
  }

  void _lockedTap() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_l10n.lockedLesson),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectTab(int index) => setState(() => _tab = index);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: _progress.loading
                ? const Center(child: CircularProgressIndicator())
                : _progress.loadFailed
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 40),
                        const SizedBox(height: 16),
                        Text(
                          _progress.loadFailed
                              ? _l10n.loadError
                              : _l10n.saveError,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _progress.load,
                          child: Text(_l10n.tryAgain),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    key: PageStorageKey('page_$_tab'),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _brand(),
                        if (_progress.storageError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _panel(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _progress.loadFailed
                                        ? _l10n.loadError
                                        : _l10n.saveError,
                                  ),
                                  TextButton(
                                    onPressed: _progress.save,
                                    child: Text(_l10n.retrySave),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        switch (_tab) {
                          0 => _home(),
                          1 => _learn(),
                          2 => _review(),
                          _ => _settings(),
                        },
                      ],
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: _l10n.homeTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: _l10n.learnTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_edu_outlined),
            selectedIcon: Icon(Icons.history_edu_rounded),
            label: _l10n.reviewTab,
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            label: _l10n.settingsTab,
          ),
        ],
      ),
    ),
  );

  Widget _brand() => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.gesture_rounded, color: Colors.white, size: 25),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'uigarjin',
              style: TextStyle(
                fontSize: 23,
                letterSpacing: -0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _l10n.mongolianScript,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      Container(
        key: const Key('progressPill'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFEBEDE4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.spa_outlined, size: 17, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              '${_progress.completedCount}/${_progress.totalCount}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _home() {
    final next = widget.letters
        .where((c) => c.id == _progress.nextId)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _eyebrow(_l10n.dailyEyebrow),
        const SizedBox(height: 10),
        Text(_l10n.homeTitle, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text(_l10n.homeDescription),
        const SizedBox(height: 26),
        _hero(next),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _stat(
                '${_progress.completedCount}',
                _l10n.formsPracticed,
                Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _stat(
                '${_progress.practiceCount}',
                _l10n.lessonsFinished,
                Icons.edit_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              _l10n.learningJourney,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => _selectTab(1),
              child: Text(_l10n.viewAll),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _eyebrow(_l10n.collectionEyebrow),
              const SizedBox(height: 10),
              Text(
                _l10n.firstStrokes,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(_l10n.unitSummary(widget.letters.length)),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress.fraction,
                  minHeight: 6,
                  backgroundColor: AppColors.line,
                  semanticsLabel: _l10n.collectionProgress,
                  semanticsValue: _l10n.percentSpoken(
                    (_progress.fraction * 100).round(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _l10n.percentExplored((_progress.fraction * 100).round()),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              PrimaryActionButton(
                label: _l10n.exploreLetters,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _selectTab(1),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _contentNote(),
      ],
    );
  }

  Widget _hero(CharacterDefinition? next) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      gradient: AppGradients.hero,
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _l10n.nextStepEyebrow,
                    style: TextStyle(
                      color: Color(0xFFD6DFB8),
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    next == null
                        ? _l10n.allCompleteTitle
                        : _progress.completedCount == 0
                        ? _l10n.firstLetterTitle
                        : _l10n.keepPracticingTitle,
                    style: const TextStyle(
                      fontSize: 29,
                      height: 1.15,
                      color: Colors.white,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    next == null
                        ? _l10n.allCompleteDescription
                        : _l10n.letterTitle(
                            next.cyrillic,
                            next.transliteration,
                            _l10n.form(next.form),
                          ),
                    style: const TextStyle(
                      color: Color(0xFFD5E2DB),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (next != null) ...[
              const SizedBox(width: 12),
              ExcludeSemantics(
                child: Container(
                  width: 76,
                  height: 134,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    borderRadius: BorderRadius.circular(38),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: CustomPaint(
                    painter: MiniGlyphPainter(
                      character: next,
                      color: const Color(0xFFEDD5B4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('continueLearningButton'),
          onPressed: next == null
              ? () => _selectTab(2)
              : () => _openLesson(next),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE5D5B5),
            foregroundColor: AppColors.primaryDark,
          ),
          icon: Icon(
            next == null ? Icons.replay_rounded : Icons.arrow_forward_rounded,
            size: 20,
          ),
          label: Text(
            next == null
                ? _l10n.reviewLetters
                : _progress.completedCount == 0
                ? _l10n.beginPractice
                : _l10n.continueLearning,
          ),
        ),
      ],
    ),
  );

  Widget _learn() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _eyebrow(_l10n.journeyEyebrow),
      const SizedBox(height: 10),
      Text(
        _l10n.firstStrokes,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 10),
      Text(_l10n.learnDescription),
      const SizedBox(height: 20),
      _contentNote(),
      const SizedBox(height: 22),
      for (var i = 0; i < widget.letters.length; i++)
        _letterTile(widget.letters[i], i + 1),
    ],
  );

  Widget _review() {
    final completed = widget.letters
        .where((c) => _progress.isCompleted(c.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _eyebrow(_l10n.reviewEyebrow),
        const SizedBox(height: 10),
        Text(
          _l10n.reviewTitle,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(_l10n.reviewDescription),
        const SizedBox(height: 24),
        if (completed.isEmpty)
          _panel(
            child: Column(
              children: [
                const Icon(
                  Icons.history_edu_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _l10n.emptyReviewTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(_l10n.emptyReviewDescription, textAlign: TextAlign.center),
                const SizedBox(height: 22),
                PrimaryActionButton(
                  label: _l10n.findFirstLesson,
                  onPressed: () => _selectTab(1),
                ),
              ],
            ),
          ),
        for (var i = 0; i < completed.length; i++)
          _letterTile(completed[i], i + 1),
      ],
    );
  }

  Widget _settings() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _eyebrow(_l10n.settingsEyebrow),
      const SizedBox(height: 10),
      Text(
        _l10n.settingsTitle,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      const SizedBox(height: 12),
      Text(_l10n.settingsDescription),
      const SizedBox(height: 24),
      _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(_l10n.languageDescription),
            const SizedBox(height: 14),
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  key: const Key('languageSelector'),
                  value: _progress.languageCode,
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(_l10n.englishLanguage),
                    ),
                    DropdownMenuItem(
                      value: 'mn',
                      child: Text(_l10n.mongolianLanguage),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      unawaited(_progress.updateSettings(languageCode: value));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _panel(
        child: Column(
          children: [
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(_l10n.beginnerGuidance),
              subtitle: Text(_l10n.beginnerDescription),
              value: _progress.beginner,
              onChanged: (v) => _progress.updateSettings(beginner: v),
            ),
            const Divider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(_l10n.polishStrokes),
              subtitle: Text(_l10n.polishDescription),
              value: _progress.beautify,
              onChanged: (v) => _progress.updateSettings(beautify: v),
            ),
            const Divider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(_l10n.hapticFeedback),
              subtitle: Text(_l10n.hapticDescription),
              value: _progress.haptics,
              onChanged: (v) => _progress.updateSettings(haptics: v),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.offline_pin_outlined, color: AppColors.primary),
            SizedBox(height: 12),
            Text(
              _l10n.offlineTitle,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(_l10n.offlineDescription),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _contentNote(),
      const SizedBox(height: 24),
      Text(
        _l10n.edition,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          letterSpacing: 1.5,
          color: AppColors.textMuted,
        ),
      ),
    ],
  );

  Widget _letterTile(CharacterDefinition character, int number) {
    final complete = _progress.isCompleted(character.id);
    final unlocked = _progress.isUnlocked(character.id);
    final score = _progress.bestScore(character.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _progress.isNextUp(character.id)
                ? AppColors.primary
                : AppColors.line,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('node_${character.id}'),
          onTap: unlocked ? () => _openLesson(character) : _lockedTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Semantics(
                  label: _l10n.referencePreview(
                    character.cyrillic,
                    _l10n.form(character.form),
                  ),
                  image: true,
                  child: Container(
                    width: 48,
                    height: 68,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? const Color(0xFFEEF1E7)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CustomPaint(
                      painter: MiniGlyphPainter(
                        character: character,
                        color: unlocked
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.lessonNumber(number.toString().padLeft(2, '0')),
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.2,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${character.cyrillic} · ${character.transliteration}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        score == null
                            ? _l10n.form(character.form)
                            : _l10n.formBestScore(
                                _l10n.form(character.form),
                                score.round(),
                              ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  complete
                      ? Icons.check_circle_rounded
                      : unlocked
                      ? Icons.arrow_forward_rounded
                      : Icons.lock_rounded,
                  color: unlocked ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, IconData icon) => _panel(
    padding: 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    ),
  );

  Widget _contentNote() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0E9DC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: AppColors.secondaryDark,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            _l10n.collectionNote,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.secondaryDark,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _panel({required Widget child, double padding = 22}) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.line),
    ),
    child: child,
  );

  Widget _eyebrow(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: AppColors.primary,
    ),
  );
}
