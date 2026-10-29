import 'package:e_clinic_core/core.dart';
import '../../models/clinic/clinical_order.dart';

/// Clinical Orders — X-ray, imaging, lab and referrals; reports reach patients once completed.
class ClinicalOrderRepository {
  const ClinicalOrderRepository(this._api);

  final ApiClient _api;

  Future<Paged<ClinicalOrder>> list(ListQuery query) => _api.list('clinical-orders', query, ClinicalOrder.fromJson);

  Future<ClinicalOrder> get(String id) => _api.get('clinical-orders/$id', objectOf(ClinicalOrder.fromJson));
}
