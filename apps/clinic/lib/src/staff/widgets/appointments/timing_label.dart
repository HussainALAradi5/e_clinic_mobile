import 'package:flutter/material.dart';

class TimingLabel extends StatelessWidget {
  const TimingLabel({super.key, required this.timing});

  final ({String text, bool late}) timing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = timing.late ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(timing.late ? Icons.schedule_rounded : Icons.hourglass_bottom_rounded, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          timing.text,
          style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
