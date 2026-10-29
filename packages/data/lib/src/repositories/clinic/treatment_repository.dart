import 'package:e_clinic_core/core.dart';
import '../../models/clinic/treatment.dart';

class TreatmentRepository {
  const TreatmentRepository(this._api);

  final ApiClient _api;

  Future<Paged<Treatment>> list(ListQuery query) => _api.list('treatments', query, Treatment.fromJson);

  Future<List<TreatmentSession>> sessions(String id) =>
      _api.get('treatments/$id/sessions', listOf(TreatmentSession.fromJson));
}
