import 'package:e_clinic_core/core.dart';

import '../../models/clinic/patient.dart';
import '../../models/clinic/patient_timeline_entry.dart';

/// Patient files (staff).
class PatientRepository {
  const PatientRepository(this._api);

  final ApiClient _api;

  Future<Paged<Patient>> list(ListQuery query) => _api.list('patients', query, Patient.fromJson);

  Future<Patient> get(String id) => _api.get('patients/$id', objectOf(Patient.fromJson));

  /// A patient by file number (`PRS-…`) or national ID, identity only — to confirm before breaking the glass.
  Future<PatientLookup?> lookup({String? code, String? nationalId}) => _api.get(
    'patients/lookup',
    (data) => data == null ? null : PatientLookup.fromJson(data as Map<String, dynamic>),
    query: {'code': code, 'national_id': nationalId},
  );

  /// Break the glass: opens the file for the shift with [reason]; audited, admins are told.
  Future<Patient> emergencyAccess(String id, String reason) => _api.post(
    'patients/$id/emergency-access',
    (data) => Patient.fromJson((data! as Map<String, dynamic>)['patient'] as Map<String, dynamic>),
    body: {'reason': reason},
  );

  /// The care team's medical history; only the fields given change.
  Future<Patient> updateMedicalHistory(
    String id, {
    required int version,
    String? allergies,
    String? chronicConditions,
    String? familyHistory,
    String? surgicalHistory,
  }) => _api.put(
    'patients/$id/medical-history',
    objectOf(Patient.fromJson),
    body: {
      'version': version,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'family_history': familyHistory,
      'surgical_history': surgicalHistory,
    },
  );

  /// Visits, treatments and orders, newest first.
  Future<List<PatientTimelineEntry>> timeline(String id) =>
      _api.get('patients/$id/timeline', listOf(PatientTimelineEntry.fromJson));
}
