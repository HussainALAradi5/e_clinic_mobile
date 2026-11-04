import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../constants/billing/fee_text.dart';

/// The patient's visit fees: what was charged and why, waived ones crossed out with the reason, and the rule
/// that explains them. Rows slide in one after another.
class FeeCard extends StatelessWidget {
  const FeeCard({super.key, required this.fees});

  final List<AppointmentFee> fees;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_busy_rounded, color: scheme.error),
                const SizedBox(width: 10),
                Text(FeeText.title, style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(FeeText.rules, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            const Divider(height: 20),
            for (final (i, fee) in fees.indexed)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Motion.of(context, Motion.base + Duration(milliseconds: 60 * i)),
                curve: Motion.ease,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(FeeText.types[fee.type] ?? fee.type, style: theme.textTheme.bodyMedium),
                            Text(
                              fee.waived && fee.waiverReason != null
                                  ? '${FeeText.waived} · ${fee.waiverReason}'
                                  : FeeText.visit(
                                      fee.appointment.code,
                                      ClinicClock.date(fee.appointment.scheduledDate),
                                    ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        fee.amount.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fee.waived ? scheme.onSurfaceVariant : scheme.error,
                          decoration: fee.waived ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
