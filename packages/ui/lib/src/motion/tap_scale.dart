import 'package:flutter/widgets.dart';

import 'motion.dart';

/// Press feedback: [child] sinks a little while a finger is on it and springs back on release. It does not handle
/// the tap itself, so it wraps any button, card or tile without changing what it does.
class TapScale extends StatefulWidget {
  const TapScale({super.key, required this.child, this.pressed = 0.94});

  final Widget child;

  /// Scale while pressed.
  final double pressed;

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _down ? widget.pressed : 1,
      duration: Motion.of(context, Motion.fast),
      curve: Motion.ease,
      child: widget.child,
    ),
  );
}
