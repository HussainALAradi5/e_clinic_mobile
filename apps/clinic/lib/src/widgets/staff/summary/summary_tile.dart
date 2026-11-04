import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/month_summary_text.dart';

/// One figure of the month and its change from the month before (green when the change is good news).
class SummaryTile extends StatelessWidget {
  const SummaryTile({
    super.key,
    required this.label,
    required this.now,
    required this.before,
    this.lowerIsBetter = false,
  });

  final String label;

  /// A money map (`{amount, currency}`) or a count.
  final Object? now;
  final Object? before;
  final bool lowerIsBetter;

  static num _value(Object? v) => v is Map ? (MoneyFormat.toMinor(v['amount'] as String?) ?? 0) : (v as num? ?? 0);

  /// Percent change from the month before; null when there was nothing to compare with.
  int? get change {
    final a = _value(now);
    final b = _value(before);
    if (b == 0) return a == 0 ? 0 : null;
    return ((a - b) / b.abs() * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = change;
    final good = c != null && c != 0 && (lowerIsBetter ? c < 0 : c > 0);
    final color = c == null || c == 0 ? scheme.onSurfaceVariant : (good ? Colors.green.shade700 : scheme.error);
    final value = now;
    final shown = value is Map ? MoneyFormat.format(value['amount'] as String? ?? '0', MoneyFormat.currency) : '$value';
    final note = c == null ? MonthSummaryText.newFigure : '${c > 0 ? '+' : ''}$c %';
    return TapScale(
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              FittedBox(child: Text(shown, style: theme.textTheme.titleLarge)),
              const SizedBox(height: 2),
              Row(
                children: [
                  if (c != null && c != 0)
                    Icon(c > 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded, size: 14, color: color),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '$note ${MonthSummaryText.vsBefore}',
                      style: theme.textTheme.labelSmall?.copyWith(color: color),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
