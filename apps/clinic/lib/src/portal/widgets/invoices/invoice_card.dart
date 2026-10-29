import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import 'invoice_detail.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return ExpandableCard(
      header: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.number, style: theme.textTheme.titleSmall),
                if (invoice.issueDate != null) Text(ClinicClock.date(invoice.issueDate!), style: muted),
                const SizedBox(height: 8),
                StatusChip(enumName: 'InvoiceStatus', value: invoice.status),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(invoice.total.label, style: theme.textTheme.titleSmall),
              if (invoice.owing)
                Text(
                  '${invoice.balanceDue.label} due',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
      details: (_) => InvoiceDetail(invoiceId: invoice.id),
    );
  }
}
