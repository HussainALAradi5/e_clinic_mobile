import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../feedback/app_snack.dart';
import '../feedback/sheets.dart';

part 'app_button_action_cancelled.dart';
part 'app_button_button_lock.dart';
part 'app_button_button_variant.dart';
part 'app_button_phase.dart';

/// The only button for actions that call the server: locks on tap (a second tap is ignored), shows a spinner,
/// then a tick; optional confirmation sheet; errors show as a snack and unlock the button.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.lock = ButtonLock.untilDone,
    this.confirm,
    this.before,
    this.expand = false,
  });

  final String label;

  /// Null disables the button.
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonLock lock;
  final ConfirmConfig? confirm;

  /// Asks what the action needs before the button locks (a reason, a follow-up date); false = the user backed out.
  /// Keeps the spinner for the server call only, never while a sheet is open.
  final Future<bool> Function()? before;

  /// Full width (primary action at the bottom of a screen).
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  var _phase = _Phase.idle;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _run() async {
    final action = widget.onPressed;
    if (action == null || _phase == _Phase.busy || _phase == _Phase.locked) return;
    if (widget.confirm != null && !await showConfirmSheet(context, widget.confirm!)) return;
    if (widget.before != null && !await widget.before!()) return;
    if (!mounted) return;
    setState(() => _phase = _Phase.busy);
    unawaited(HapticFeedback.selectionClick());
    try {
      // A short minimum keeps the spinner from flickering on fast answers.
      await Future.wait([action(), Future<void>.delayed(const Duration(milliseconds: 300))]);
      if (!mounted) return;
      setState(() => _phase = widget.lock == ButtonLock.once ? _Phase.locked : _Phase.done);
      if (widget.lock == ButtonLock.untilDone) {
        _reset = Timer(const Duration(milliseconds: 1200), () {
          if (mounted) setState(() => _phase = _Phase.idle);
        });
      }
    } on ActionCancelled {
      if (mounted) setState(() => _phase = _Phase.idle);
    } catch (error) {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && (_phase == _Phase.idle || _phase == _Phase.done);
    final onPressed = enabled ? _run : null;
    final leading = switch (_phase) {
      _Phase.busy => const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.4)),
      _Phase.done || _Phase.locked => const Icon(Icons.check_rounded, size: 20),
      _Phase.idle => widget.icon == null ? null : Icon(widget.icon, size: 20),
    };
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading, const SizedBox(width: 8)],
        Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
      ],
    );
    final button = switch (widget.variant) {
      ButtonVariant.filled => FilledButton(onPressed: onPressed, child: child),
      ButtonVariant.tonal => FilledButton.tonal(onPressed: onPressed, child: child),
      ButtonVariant.outlined => OutlinedButton(onPressed: onPressed, child: child),
      ButtonVariant.text => TextButton(onPressed: onPressed, child: child),
    };
    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
