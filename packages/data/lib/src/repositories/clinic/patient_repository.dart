import 'package:e_clinic_core/core.dart';

import '../../models/clinic/patient.dart';
import '../../models/clinic/patient_timeline_entry.dart';

/// Patient files (staff).
class PatientRepository {
  const PatientRepository(this._api);

  final ApiClient _api;

  Future<Paged<Patient>> list(ListQuery query) => _api.list('patients', query, Patient.fromJson);

  Future<Patient> get(String id) => _api.get('patients/$id', objectOf(Patient.fromJson));

  /// Visits, treatments and orders, newest first.
  Future<List<PatientTimelineEntry>> timeline(String id) =>
      _api.get('patients/$id/timeline', listOf(PatientTimelineEntry.fromJson));
}
