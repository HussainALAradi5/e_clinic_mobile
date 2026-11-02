import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/portal/portal_providers.dart';
import '../../widgets/portal/invoices/due_card.dart';
import '../../widgets/portal/invoices/invoice_card.dart';

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
              DueCard(due: due),
              const SizedBox(height: 16),
              if (invoices.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No invoices yet',
                  message: 'Invoices appear here once the clinic issues them after a visit.',
                )
              else
                for (final invoice in invoices) ...[InvoiceCard(invoice: invoice), const SizedBox(height: 12)],
            ],
          );
        },
      ),
    ),
  );
}
