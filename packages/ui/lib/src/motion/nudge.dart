import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'motion.dart';

/// Swings [child] sideways once and rings it with the primary colour each time [trigger] changes — the message
/// you chose to reply to, a row that needs a look. A null [trigger] stays still.
class Nudge extends StatelessWidget {
  const Nudge({super.key, required this.trigger, required this.child, this.distance = 10, this.radius = 18});

  final Object? trigger;
  final Widget child;

  /// How far it swings, in logical pixels.
  final double distance;

  /// Corner radius of the ring (match the child's shape).
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (trigger == null || !Motion.enabled(context)) return child;
    final primary = Theme.of(context).colorScheme.primary;
    return TweenAnimationBuilder<double>(
      key: ValueKey(trigger),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      builder: (context, t, child) {
        // One swing out and back, with the ring fading as it returns.
        final wave = math.sin(t * math.pi);
        return Transform.translate(
          offset: Offset(wave * distance, 0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.45 * wave),
                  spreadRadius: 3 * wave,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
