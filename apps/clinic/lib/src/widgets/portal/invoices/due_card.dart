import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/portal/invoice_text.dart';

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
            owing ? CommonText.toPay : InvoiceText.allSettled,
            style: theme.textTheme.labelLarge?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            owing ? due.label : InvoiceText.nothingToPay,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            InvoiceText.payAtCashier,
            style: theme.textTheme.bodySmall?.copyWith(
              color: owing ? scheme.onTertiaryContainer : scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
