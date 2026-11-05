import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/portal/invoice_text.dart';
import '../../../controllers/portal/portal_providers.dart';
import '../../common/document_buttons.dart';
import 'coverage_summary.dart';
import 'pay_online_button.dart';
import 'total_row.dart';

class InvoiceDetail extends ConsumerWidget {
  const InvoiceDetail({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return AsyncBody(
      value: ref.watch(invoiceDetailProvider(invoiceId)),
      onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId)),
      loading: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      data: (invoice) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final line in invoice.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.description, style: theme.textTheme.bodyMedium),
                          if (double.tryParse(line.quantity) != 1)
                            Text('${line.quantity} × ${line.unitPrice.label}', style: muted),
                        ],
                      ),
                    ),
                    Text(line.lineTotal.label, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            const Divider(height: 16),
            TotalRow(label: InvoiceText.total, value: invoice.total.label, bold: true),
            TotalRow(label: InvoiceText.paid, value: invoice.paidAmount.label),
            if (invoice.owing) TotalRow(label: InvoiceText.leftToPay, value: invoice.balanceDue.label, bold: true),
            // The insurer's part and mine, when my insurance covers this invoice.
            if (ref.watch(invoiceCoverageProvider(invoiceId)).value case final c? when c.covered) ...[
              const SizedBox(height: 12),
              CoverageSummary(coverage: c),
            ],
            if (invoice.payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                InvoiceText.payments,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              for (final payment in invoice.payments)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const Icon(Icons.payments_outlined),
                  title: Text(payment.amount.label),
                  subtitle: Text(
                    [
                      catalog.label('PaymentMethod', payment.method),
                      if (payment.cardLast4 != null) '•••• ${payment.cardLast4}',
                      ClinicClock.dateTime(payment.paidAt),
                    ].join(' · '),
                  ),
                  trailing: StatusChip(enumName: 'PaymentStatus', value: payment.status),
                ),
            ],
            if (invoice.owing &&
                ref.watch(accessProvider).can('online_payments.create') &&
                (ref.watch(onlinePaymentsEnabledProvider).value ?? false)) ...[
              const SizedBox(height: 16),
              PayOnlineButton(invoiceId: invoice.id),
            ],
            const SizedBox(height: 16),
            DocumentButtons(type: DocumentType.invoice, recordId: invoice.id),
          ],
        ),
      ),
    );
  }
}
