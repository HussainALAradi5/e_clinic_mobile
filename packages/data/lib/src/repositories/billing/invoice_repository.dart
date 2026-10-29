import 'package:e_clinic_core/core.dart';

import '../../models/billing/invoice.dart';

class InvoiceRepository {
  const InvoiceRepository(this._api);

  final ApiClient _api;

  Future<Paged<Invoice>> list(ListQuery query) => _api.list('billing/invoices', query, Invoice.fromJson);

  Future<Invoice> get(String id) => _api.get('billing/invoices/$id', objectOf(Invoice.fromJson));
}
