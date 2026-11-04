import 'package:flutter/widgets.dart';

import 'motion.dart';

/// Grows [child] in with a small overshoot the first time it is built — a selected tab icon, a badge, a new chip.
/// Give it a new [key] to play it again.
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.from = 0.7});

  final Widget child;

  /// Starting scale.
  final double from;

  @override
  Widget build(BuildContext context) {
    if (!Motion.enabled(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from, end: 1),
      duration: Motion.slow,
      curve: Motion.pop,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
