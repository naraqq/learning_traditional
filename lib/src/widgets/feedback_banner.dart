import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Short feedback area ("Correct!", "Start a little higher", etc.).
class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({super.key, required this.message, required this.tone});

  final String message;
  final FeedbackTone tone;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color accent;
    final IconData icon;
    switch (tone) {
      case FeedbackTone.success:
        background = AppColors.success.withValues(alpha: 0.12);
        accent = AppColors.successDark;
        icon = Icons.check_rounded;
      case FeedbackTone.error:
        background = AppColors.error.withValues(alpha: 0.10);
        accent = AppColors.errorDark;
        icon = Icons.close_rounded;
      case FeedbackTone.neutral:
        background = AppColors.ink.withValues(alpha: 0.05);
        accent = AppColors.textMuted;
        icon = Icons.info_outline_rounded;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

enum FeedbackTone { neutral, success, error }
