import 'package:flutter/widgets.dart';

/// One set of motion timings and curves for the whole app. Every motion widget asks [enabled] first, so the
/// system "remove animations" setting turns them all off.
abstract final class Motion {
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 420);

  static const ease = Curves.easeOutCubic;
  static const spring = Curves.elasticOut;
  static const pop = Curves.easeOutBack;

  /// False when the user asked the system for fewer animations.
  static bool enabled(BuildContext context) => !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);

  /// [duration], or none when animations are off.
  static Duration of(BuildContext context, Duration duration) => enabled(context) ? duration : Duration.zero;
}
