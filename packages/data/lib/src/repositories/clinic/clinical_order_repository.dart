import 'package:e_clinic_core/core.dart';

import '../../enums/clinic/clinical_order_type.dart';
import '../../models/clinic/clinical_order.dart';

/// Clinical Orders — X-ray, imaging, lab and referrals; reports reach patients once completed.
class ClinicalOrderRepository {
  const ClinicalOrderRepository(this._api);

  final ApiClient _api;

  Future<Paged<ClinicalOrder>> list(ListQuery query) => _api.list('clinical-orders', query, ClinicalOrder.fromJson);

  Future<ClinicalOrder> get(String id) => _api.get('clinical-orders/$id', objectOf(ClinicalOrder.fromJson));

  /// Open orders (pending and in progress), most urgent first, then oldest; [types] narrows it (empty = all).
  Future<List<ClinicalOrder>> worklist({List<ClinicalOrderType> types = const []}) => _api.get(
    'clinical-orders/worklist',
    listOf(ClinicalOrder.fromJson),
    query: {for (final (i, type) in types.indexed) 'types[$i]': wireValue(type)},
  );

  Future<ClinicalOrder> start(String id) => _api.patch('clinical-orders/$id/start', objectOf(ClinicalOrder.fromJson));

  /// Writes the result; the patient sees it in their results from now on.
  Future<ClinicalOrder> complete(String id, {required String report, bool? isAbnormal}) => _api.patch(
    'clinical-orders/$id/complete',
    objectOf(ClinicalOrder.fromJson),
    body: {'report': report, 'is_abnormal': ?isAbnormal},
  );

  Future<ClinicalOrder> cancel(String id, String reason) =>
      _api.patch('clinical-orders/$id/cancel', objectOf(ClinicalOrder.fromJson), body: {'reason': reason});
}
