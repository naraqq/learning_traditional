import '../../l10n/localization.dart';
import 'package:flutter/material.dart';
import '../validation/stroke_validator.dart';

class ToleranceToggle extends StatelessWidget {
  const ToleranceToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });
  final ToleranceMode mode;
  final ValueChanged<ToleranceMode> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final value in ToleranceMode.values)
        ChoiceChip(
          label: Text(
            value == ToleranceMode.beginner
                ? context.l10n.beginner
                : context.l10n.advanced,
          ),
          selected: mode == value,
          onSelected: (_) => onChanged(value),
        ),
    ],
  );
}
