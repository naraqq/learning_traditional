import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/localization.dart';
import '../theme/app_theme.dart';

/// Shown at app launch while saved progress and preferences load.
///
/// Plays a fixed ~1.5s entrance sequence (brush stroke → brand icon with a
/// spring/glow settle → title and subtitle) on the app's own hero gradient,
/// then calls [onFinish] once — but only once both the animation has
/// finished *and* [isLoading] has turned false, so a slow store read never
/// gets cut off and a fast one never feels like a flash. If [isLoading]
/// turns false only after the animation already finished, [onFinish] fires
/// immediately on that transition instead of waiting further.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.isLoading,
    required this.onFinish,
  });

  /// Whether the app is still doing first-launch work (e.g. reading saved
  /// progress). The splash won't hand off while this is true.
  final bool isLoading;

  /// Called exactly once, when it's safe to move on to the next screen.
  final VoidCallback onFinish;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1500);

  late final AnimationController _entrance;
  late final AnimationController _pulse;

  late final Animation<double> _bgOpacity;
  late final Animation<double> _strokeGrow;
  late final Animation<double> _strokeFade;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconGlow;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textOffset;
  late final Animation<double> _loadingOpacity;

  bool _entranceFinished = false;
  bool _finished = false;
  bool _reduceMotionHandled = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onEntranceStatus);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    // 0.0s-0.4s: background fades in, brush stroke grows top-to-bottom.
    _bgOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.27, curve: Curves.easeOut),
    );
    _strokeGrow = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.0, 0.27, curve: Curves.easeOut),
    );
    // 0.4s-0.8s: the stroke resolves into the brand icon with a spring/glow.
    _strokeFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.25, 0.36, curve: Curves.easeIn),
    );
    _iconOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.27, 0.42, curve: Curves.easeIn),
    );
    _iconScale = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.27, 0.53, curve: Curves.easeOutBack),
    );
    _iconGlow = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.27, 0.60, curve: Curves.easeOut),
    );
    // 0.8s-1.2s: title and subtitle slide up with a fade-in.
    _textOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.53, 0.80, curve: Curves.easeOut),
    );
    _textOffset = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entrance,
            curve: const Interval(0.53, 0.80, curve: Curves.easeOutCubic),
          ),
        );
    _loadingOpacity = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.66, 0.9, curve: Curves.easeOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reduceMotionHandled) return;
    _reduceMotionHandled = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _entrance.value = 1;
      _pulse.stop();
      _entranceFinished = true;
      _maybeFinish();
    } else {
      _entrance.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading && !widget.isLoading) _maybeFinish();
  }

  void _onEntranceStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _entranceFinished = true;
      _maybeFinish();
    }
  }

  void _maybeFinish() {
    if (_finished || !_entranceFinished || widget.isLoading) return;
    _finished = true;
    // This can be reached from didChangeDependencies (reduced motion) or a
    // status/widget-update callback that may itself run mid-build; calling
    // onFinish() synchronously there can ask an ancestor to setState while
    // the tree is still building. A post-frame callback defers it to a safe
    // point right after the current frame instead.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_entrance, _pulse]),
        builder: (context, _) {
          return Opacity(
            opacity: _bgOpacity.value,
            child: DecoratedBox(
              decoration: const BoxDecoration(gradient: AppGradients.hero),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 96,
                          height: 96,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_strokeFade.value < 1)
                                Opacity(
                                  opacity: (1 - _strokeFade.value).clamp(
                                    0.0,
                                    1.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      width: 6,
                                      height: 84 * _strokeGrow.value,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              Opacity(
                                opacity: _iconOpacity.value,
                                child: Transform.scale(
                                  scale: 0.6 + 0.4 * _iconScale.value,
                                  child: Container(
                                    width: 76,
                                    height: 76,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.28,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.30 * _iconGlow.value,
                                          ),
                                          blurRadius: 28 * _iconGlow.value,
                                          spreadRadius: 1 * _iconGlow.value,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.gesture_rounded,
                                      color: Colors.white,
                                      size: 42,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Opacity(
                          opacity: _textOpacity.value,
                          child: FractionalTranslation(
                            translation: _textOffset.value,
                            child: Column(
                              children: [
                                Text(
                                  l10n.mongolianScript,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    letterSpacing: -0.6,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.splashSubtitle,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 56,
                    child: Opacity(
                      opacity: _loadingOpacity.value,
                      child: Center(
                        child: _LoadingDots(progress: _pulse.value),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Three small dots pulsing in a traveling wave — a lighter-weight, more
/// on-brand alternative to a bare [CircularProgressIndicator].
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.progress});

  /// 0.0-1.0, from a linearly repeating [AnimationController].
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < 3; i++) _dot(i)],
    );
  }

  Widget _dot(int index) {
    final phase = (progress + index * 0.18) % 1.0;
    final wave = (math.sin(phase * 2 * math.pi) + 1) / 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Opacity(
        opacity: 0.35 + 0.65 * wave,
        child: Transform.scale(
          scale: 0.6 + 0.4 * wave,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
