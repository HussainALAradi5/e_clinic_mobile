import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// One balance movement: what it was, when, why, the signed amount and the balance after it.
class WalletEntryRow extends StatelessWidget {
  const WalletEntryRow({super.key, required this.entry});

  final WalletEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final when = entry.createdAt == null ? '' : ClinicClock.dateTime(entry.createdAt!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          StatusChip(enumName: 'WalletEntryType', value: entry.type),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              [when, if (entry.reason != null) entry.reason!].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.isCredit ? '+' : '−'}${entry.amount.label}',
                style: theme.textTheme.labelLarge?.copyWith(color: entry.isCredit ? scheme.primary : scheme.error),
              ),
              Text(
                entry.balanceAfter.label,
                style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
