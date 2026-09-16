import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../../l10n/localization.dart';

/// Top progress indicator showing how many strokes of the current exercise
/// are complete — a gradient-filled, animated pill rather than a flat
/// Material [LinearProgressIndicator].
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.progress,
    required this.semanticLabel,
  });

  final String semanticLabel;

  /// 0.0-1.0.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      value: context.l10n.percentSpoken(
        (progress.clamp(0.0, 1.0) * 100).round(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 10,
          color: AppColors.locked.withValues(alpha: 0.6),
          child: AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(gradient: AppGradients.primary),
            ),
          ),
        ),
      ),
    );
  }
}
