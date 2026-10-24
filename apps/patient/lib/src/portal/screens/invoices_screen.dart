import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portal_providers.dart';

/// `/invoices` — issued invoices with what is left to pay; each opens to its lines and payments.
class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My invoices')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(invoicesProvider.future),
      child: AsyncBody(
        value: ref.watch(invoicesProvider),
        onRetry: () => ref.invalidate(invoicesProvider),
        data: (invoices) {
          final due = Money.sum(invoices.map((i) => i.balanceDue));
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _DueCard(due: due),
              const SizedBox(height: 16),
              if (invoices.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No invoices yet',
                  message: 'Invoices appear here once the clinic issues them after a visit.',
                )
              else
                for (final invoice in invoices) ...[
                  _InvoiceCard(invoice: invoice),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    ),
  );
}

class _DueCard extends StatelessWidget {
  const _DueCard({required this.due});

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

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

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
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.tertiary, fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
      details: (_) => _InvoiceDetail(invoiceId: invoice.id),
    );
  }
}

class _InvoiceDetail extends ConsumerWidget {
  const _InvoiceDetail({required this.invoiceId});

  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return AsyncBody(
      value: ref.watch(invoiceDetailProvider(invoiceId)),
      onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId)),
      loading: const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
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
            _TotalRow(label: 'Total', value: invoice.total.label, bold: true),
            _TotalRow(label: 'Paid', value: invoice.paidAmount.label),
            if (invoice.owing) _TotalRow(label: 'Left to pay', value: invoice.balanceDue.label, bold: true),
            if (invoice.payments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Payments', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
          ],
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: bold ? FontWeight.w700 : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [Expanded(child: Text(label, style: style)), Text(value, style: style)]),
    );
  }
}
