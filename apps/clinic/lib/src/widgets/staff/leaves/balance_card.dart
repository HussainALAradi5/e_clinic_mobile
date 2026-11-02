import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../utilities/staff/formatters.dart';

/// Days left of one leave type this year, with used and waiting days under it.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final LeaveBalance balance;

  static String _days(String value) => formatQuantity(double.tryParse(value) ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final remaining = balance.remainingDays;
    final pending = double.tryParse(balance.pendingDays) ?? 0;
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              balance.leaveType.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(
              remaining == null ? 'No limit' : _days(remaining),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(remaining == null ? '' : 'days left', style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            const SizedBox(height: 6),
            Text(
              ['${_days(balance.usedDays)} used', if (pending > 0) '${formatQuantity(pending)} waiting'].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
