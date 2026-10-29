import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

class DueCard extends StatelessWidget {
  const DueCard({super.key, required this.due});

  final Money due;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final owing = due.isPositive;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: owing ? scheme.tertiaryContainer : scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            owing ? 'To pay' : 'All settled',
            style: theme.textTheme.labelLarge?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            owing ? due.label : 'Nothing to pay',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Pay at the clinic's cashier desk; your receipts are kept here.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
