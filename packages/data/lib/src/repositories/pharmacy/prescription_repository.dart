import 'package:e_clinic_core/core.dart';

import '../../models/pharmacy/prescription.dart';

class PrescriptionRepository {
  const PrescriptionRepository(this._api);

  final ApiClient _api;

  Future<Paged<Prescription>> list(ListQuery query) =>
      _api.list('pharmacy/prescriptions', query, Prescription.fromJson);

  /// With what each line still needs (dispensed and remaining quantities).
  Future<Prescription> get(String id) => _api.get('pharmacy/prescriptions/$id', objectOf(Prescription.fromJson));

  /// Still to hand over at the pharmacy (valid, not fully dispensed), oldest first.
  Future<Paged<Prescription>> queue(ListQuery query) =>
      _api.list('pharmacy/prescriptions/queue', query, Prescription.fromJson);
}
