import 'package:e_clinic_core/core.dart';

import '../../enums/billing/invoice_payment_state.dart';
import '../../enums/billing/payment_method.dart';
import '../../models/billing/invoice.dart';

class InvoiceRepository {
  const InvoiceRepository(this._api);

  final ApiClient _api;

  /// [paymentState] and [method] narrow on the server (unpaid, overdue … / paid by cash, card …).
  Future<Paged<Invoice>> list(ListQuery query, {InvoicePaymentState? paymentState, PaymentMethod? method}) => _api.list(
    'billing/invoices',
    query,
    Invoice.fromJson,
    extra: {
      if (paymentState != null) 'payment_state': wireValue(paymentState),
      if (method != null) 'method': wireValue(method),
    },
  );

  Future<Invoice> get(String id) => _api.get('billing/invoices/$id', objectOf(Invoice.fromJson));
}
