import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/portal/portal_providers.dart';
import '../../widgets/billing/wallet_card.dart';
import '../../widgets/common/date_range_chip.dart';
import '../../widgets/common/enum_filter_chips.dart';
import '../../widgets/portal/invoices/due_card.dart';
import '../../widgets/portal/invoices/invoice_card.dart';

/// `/invoices` — issued invoices with what is left to pay; each opens to its lines and payments. Filters (on the
/// server): how it stands with its payments, and how it was paid; each invoice wears both as coloured badges.
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  InvoicePaymentState? _state;
  PaymentMethod? _method;
  DateTimeRange? _dates;

  InvoiceFilter get _filter => (
    state: _state,
    method: _method,
    from: _dates == null ? null : ClinicClock.isoDate(_dates!.start),
    to: _dates == null ? null : ClinicClock.isoDate(_dates!.end),
  );

  @override
  Widget build(BuildContext context) {
    final filtered = _state != null || _method != null || _dates != null;
    return Scaffold(
      appBar: AppBar(title: const Text('My invoices')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(invoicesProvider(_filter).future),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          children: [
            EnumFilterChips(
              enumName: 'InvoicePaymentState',
              values: InvoicePaymentState.patientFilters,
              selected: _state,
              onSelected: (s) => setState(() => _state = s),
            ),
            const SizedBox(height: 8),
            EnumFilterChips(
              enumName: 'PaymentMethod',
              values: PaymentMethod.filters,
              selected: _method,
              onSelected: (m) => setState(() => _method = m),
            ),
            const SizedBox(height: 8),
            DateRangeChip(range: _dates, onChanged: (r) => setState(() => _dates = r)),
            const SizedBox(height: 16),
            AsyncBody(
              value: ref.watch(invoicesProvider(_filter)),
              onRetry: () => ref.invalidate(invoicesProvider(_filter)),
              data: (invoices) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // What is left to pay counts every invoice, so it shows on the unfiltered list only.
                    if (!filtered) ...[
                      DueCard(due: Money.sum(invoices.map((i) => i.balanceDue))),
                      const SizedBox(height: 16),
                      if (ref.watch(currentUserProvider)?.id case final me?) ...[
                        WalletCard(patientId: me, margin: EdgeInsets.zero),
                        const SizedBox(height: 16),
                      ],
                    ],
                    if (invoices.isEmpty)
                      EmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: filtered ? 'No invoices here' : 'No invoices yet',
                        message: filtered
                            ? 'Try another filter.'
                            : 'Invoices appear here once the clinic issues them after a visit.',
                      )
                    else
                      for (final invoice in invoices) ...[InvoiceCard(invoice: invoice), const SizedBox(height: 12)],
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
