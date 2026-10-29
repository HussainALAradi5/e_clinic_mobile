import 'package:e_clinic_core/core.dart';

import '../../models/pharmacy/prescription.dart';

class PrescriptionRepository {
  const PrescriptionRepository(this._api);

  final ApiClient _api;

  Future<Paged<Prescription>> list(ListQuery query) =>
      _api.list('pharmacy/prescriptions', query, Prescription.fromJson);
}
