import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.primary,
    this.height = 56,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: height),
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}
