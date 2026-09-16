import 'package:flutter/material.dart';
import '../../l10n/localization.dart';
import '../controllers/app_progress_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_action_button.dart';

/// First-run language picker, shown once between the splash screen and the
/// main app shell. Pre-selects whatever language [progress] already
/// resolved (device locale, or a previously saved choice) so tapping
/// Continue immediately works, but lets the learner switch before
/// committing. Later changes go through Settings instead.
class LanguageSelectScreen extends StatefulWidget {
  const LanguageSelectScreen({super.key, required this.progress});

  final AppProgressController progress;

  @override
  State<LanguageSelectScreen> createState() => _LanguageSelectScreenState();
}

class _LanguageSelectScreenState extends State<LanguageSelectScreen> {
  late String _selected = widget.progress.languageCode;

  void _confirm() {
    widget.progress.chooseLanguage(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.chooseLanguageTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.chooseLanguageSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 32),
                  _languageOption(code: 'en', label: l10n.englishLanguage),
                  const SizedBox(height: 12),
                  _languageOption(code: 'mn', label: l10n.mongolianLanguage),
                  const SizedBox(height: 32),
                  PrimaryActionButton(
                    key: const Key('languageContinueButton'),
                    label: l10n.continueButton,
                    onPressed: _confirm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _languageOption({required String code, required String label}) {
    final selected = _selected == code;
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.line,
          width: selected ? 2 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('languageOption_$code'),
        onTap: () => setState(() => _selected = code),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
