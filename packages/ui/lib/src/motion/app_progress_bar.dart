import 'package:flutter/material.dart';

import 'motion.dart';

/// A determinate bar for real progress (how much of an invoice is paid, how far a plan has come). It fills in from
/// empty when it appears and slides to new values; the percentage is written beside it when [showValue] is on and
/// is always read out by screen readers.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color,
    this.label,
    this.showValue = false,
    this.height = 6,
  });

  /// 0–1; values outside are clamped.
  final double value;

  /// Fill colour; the primary colour when null.
  final Color? color;
  final String? label;
  final bool showValue;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final target = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    final fill = color ?? scheme.primary;
    final percent = '${(target * 100).round()}%';
    return Semantics(
      label: label,
      value: percent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || showValue)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  if (label != null) Expanded(child: Text(label!, style: theme.textTheme.labelSmall)),
                  if (showValue)
                    Text(percent, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(height),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: target),
              duration: Motion.of(context, Motion.slow),
              curve: Motion.ease,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: height,
                color: fill,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
