import 'dart:async';
import 'package:flutter/material.dart';
import 'l10n/localization.dart';
import 'src/controllers/app_progress_controller.dart';
import 'src/data/mongolian_letters.dart';
import 'src/screens/home_path_screen.dart';
import 'src/screens/language_select_screen.dart';
import 'src/screens/splash_screen.dart';
import 'src/theme/app_theme.dart';
import 'src/storage/progress_store.dart';

void main() {
  runApp(const MongolianHandwritingApp());
}

/// Owns saved preferences above the Navigator so locale changes apply to
/// every route without replacing the learner's progress or navigation state.
class MongolianHandwritingApp extends StatefulWidget {
  const MongolianHandwritingApp({super.key, this.store});
  final ProgressStore? store;

  @override
  State<MongolianHandwritingApp> createState() =>
      _MongolianHandwritingAppState();
}

class _MongolianHandwritingAppState extends State<MongolianHandwritingApp> {
  late final AppProgressController _progress;

  /// Flips true once [SplashScreen] calls its `onFinish` — which it only
  /// does once its own entrance animation has finished *and* [_progress]
  /// has stopped loading, so the splash never feels rushed or overlong.
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    final preferredLocale = WidgetsBinding.instance.platformDispatcher.locales
        .where(
          (locale) =>
              locale.languageCode == 'en' || locale.languageCode == 'mn',
        )
        .firstOrNull;
    _progress = AppProgressController(
      orderedIds: [for (final letter in mongolianLetters) letter.id],
      store: widget.store ?? PreferencesProgressStore(),
      initialLanguageCode: preferredLocale?.languageCode ?? 'en',
    );
    unawaited(_progress.load());
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  /// Splash until it hands off itself; the one-time language picker once
  /// loading succeeds for a learner who hasn't chosen a language before;
  /// otherwise the app itself. A failed load skips straight to the app
  /// shell, which owns its own retry UI for that case.
  Widget get _home {
    if (!_splashDone) {
      return SplashScreen(
        isLoading: _progress.loading,
        onFinish: () => setState(() => _splashDone = true),
      );
    }
    if (!_progress.loadFailed && !_progress.languageChosen) {
      return LanguageSelectScreen(progress: _progress);
    }
    return HomePathScreen(progress: _progress);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _progress,
    builder: (_, _) => MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: Locale(_progress.languageCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _home,
    ),
  );
}
