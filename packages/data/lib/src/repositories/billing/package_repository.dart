import 'package:e_clinic_core/core.dart';

import '../../models/billing/patient_package.dart';

/// Packages I bought (the server limits a patient to their own). Selling happens at the clinic.
class PackageRepository {
  const PackageRepository(this._api);

  final ApiClient _api;

  Future<Paged<PatientPackage>> mine(ListQuery query) =>
      _api.list('billing/patient-packages', query, PatientPackage.fromJson);
}
