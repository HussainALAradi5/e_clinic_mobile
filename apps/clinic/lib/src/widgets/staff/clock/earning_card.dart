import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/earning_text.dart';
import '../../../controllers/staff/earning_providers.dart';

/// A doctor's commission so far this month; nothing for staff who are not on commission.
class EarningCard extends ConsumerWidget {
  const EarningCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earning = ref.watch(myEarningProvider).value;
    if (earning == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return PopIn(
      from: 0.94,
      child: Card(
        margin: const EdgeInsets.only(top: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(EarningText.title, style: theme.textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 6),
              Text(earning.commission.label, style: theme.textTheme.headlineSmall),
              Text(
                '${EarningText.terms(earning.commissionType, earning.rate)} · ${EarningText.visits(earning.visits)} · ${earning.revenue.label}',
                style: muted,
              ),
              const SizedBox(height: 4),
              Text(EarningText.hint, style: muted),
            ],
          ),
        ),
      ),
    );
  }
}
