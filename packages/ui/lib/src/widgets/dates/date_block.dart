import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// `SUN / 25 / OCT` block at the start of a visit or booking.
class DateBlock extends StatelessWidget {
  const DateBlock({super.key, required this.date, this.highlighted = false});

  /// ISO date (`YYYY-MM-DD`).
  final String date;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final parts = ClinicClock.parts(date);
    final foreground = highlighted ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Container(
      width: 58,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primaryContainer : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(parts.weekday, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
          Text(
            '${parts.day}',
            style: theme.textTheme.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700, height: 1.1),
          ),
          Text(parts.month, style: theme.textTheme.labelSmall?.copyWith(color: foreground)),
        ],
      ),
    );
  }
}
