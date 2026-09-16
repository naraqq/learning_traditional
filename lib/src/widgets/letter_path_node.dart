import 'package:flutter/material.dart';

import '../models/character_definition.dart';
import '../painters/mini_glyph_painter.dart';
import '../theme/app_theme.dart';

enum PathNodeState { locked, available, completed }

/// One circular node on the home path: shows a mini preview of the
/// letter's glyph, colored/decorated by [state]. When [pulse] is true (the
/// single next letter to do) it breathes a soft glow ring to draw the eye,
/// the same "start here" affordance language-learning apps use.
class LetterPathNode extends StatefulWidget {
  const LetterPathNode({
    super.key,
    required this.character,
    required this.state,
    required this.onTap,
    this.pulse = false,
  });

  final CharacterDefinition character;
  final PathNodeState state;
  final VoidCallback onTap;
  final bool pulse;

  @override
  State<LetterPathNode> createState() => _LetterPathNodeState();
}

class _LetterPathNodeState extends State<LetterPathNode>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect reduced-motion: a perpetually breathing ring is exactly the
    // kind of motion that setting is meant to suppress.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (widget.pulse && !reduceMotion) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final locked = widget.state == PathNodeState.locked;
    final completed = widget.state == PathNodeState.completed;

    final Gradient? fillGradient;
    final Color glow;
    switch (widget.state) {
      case PathNodeState.locked:
        fillGradient = null;
        glow = Colors.transparent;
      case PathNodeState.available:
        fillGradient = AppGradients.primary;
        glow = AppColors.primary;
      case PathNodeState.completed:
        fillGradient = AppGradients.success;
        glow = AppColors.success;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 104,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.pulse)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final t = _pulseController.value;
                    return Opacity(
                      opacity: (1 - t) * 0.45,
                      child: Transform.scale(scale: 1 + t * 0.28, child: child),
                    );
                  },
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              GestureDetector(
                // Locked nodes still receive the tap so the caller can show
                // a "complete the previous letter first" hint — only the
                // press scale animation is skipped for them.
                onTapDown: locked ? null : (_) => _setPressed(true),
                onTapCancel: locked ? null : () => _setPressed(false),
                onTapUp: locked ? null : (_) => _setPressed(false),
                onTap: widget.onTap,
                child: AnimatedScale(
                  scale: _pressed ? 0.92 : 1.0,
                  duration: const Duration(milliseconds: 90),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: fillGradient == null ? AppColors.locked : null,
                      gradient: fillGradient,
                      shape: BoxShape.circle,
                      border: widget.state == PathNodeState.available
                          ? Border.all(color: AppColors.secondary, width: 4)
                          : null,
                      boxShadow: locked
                          ? const []
                          : [
                              BoxShadow(
                                color: glow.withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Center(
                      child: locked
                          ? const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 30,
                            )
                          : completed
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 36,
                            )
                          : SizedBox(
                              width: 46,
                              height: 46,
                              child: CustomPaint(
                                painter: MiniGlyphPainter(
                                  character: widget.character,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${widget.character.cyrillic} · ${widget.character.transliteration}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: locked ? AppColors.textMuted : AppColors.ink,
          ),
        ),
      ],
    );
  }
}
