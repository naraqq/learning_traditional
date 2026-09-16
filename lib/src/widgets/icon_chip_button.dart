import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A small pill-shaped icon+label chip used for secondary lesson controls
/// (Undo, Clear, Show again) — reads as a designed control rather than a
/// bare Material [TextButton].
class IconChipButton extends StatelessWidget {
  const IconChipButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color = enabled
        ? AppColors.primary
        : AppColors.textMuted.withValues(alpha: 0.5);
    return Material(
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.10)
          : AppColors.locked.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
