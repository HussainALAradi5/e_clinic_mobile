import 'package:flutter/material.dart';

/// The one on / off switch of the app: a slim 40 x 22 pill with a white knob, in both themes.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, required this.onChanged});

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  static const double _width = 40;
  static const double _height = 22;
  static const double _knob = 18;
  static const double _inset = 2;
  static const double _disabledOpacity = 0.45;
  static const double _offTrackAlpha = 0.45;
  static const double _tapPadding = 13;
  static const Duration _duration = Duration(milliseconds: 160);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: _tapPadding),
          child: Opacity(
            opacity: enabled ? 1 : _disabledOpacity,
            child: AnimatedContainer(
              duration: _duration,
              curve: Curves.easeOut,
              width: _width,
              height: _height,
              padding: const EdgeInsets.all(_inset),
              decoration: BoxDecoration(
                color: value ? colors.primary : colors.outline.withValues(alpha: _offTrackAlpha),
                borderRadius: BorderRadius.circular(_height),
              ),
              child: AnimatedAlign(
                duration: _duration,
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: _knob,
                  height: _knob,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
