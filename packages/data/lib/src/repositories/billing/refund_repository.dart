import 'package:e_clinic_core/core.dart';
import '../../models/billing/refund.dart';

/// Refunds — someone other than the requester approves or rejects.
class RefundRepository {
  const RefundRepository(this._api);

  final ApiClient _api;

  Future<Paged<Refund>> list(ListQuery query) => _api.list('billing/refunds', query, Refund.fromJson);

  Future<Refund> approve(String id) => _api.post('billing/refunds/$id/approve', objectOf(Refund.fromJson));

  Future<Refund> reject(String id, String reason) =>
      _api.post('billing/refunds/$id/reject', objectOf(Refund.fromJson), body: {'reason': reason});
}
