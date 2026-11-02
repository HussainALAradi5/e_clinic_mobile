import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/refs.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

part 'patient_address.dart';
part 'patient_nationality.dart';
part 'patient_patient_lookup.dart';
part 'patient_person.dart';

/// Mirror of PatientResource. Medical fields come only with `patients.view_medical` (never in the portal);
/// staff notes are never sent to the patient themself.
@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String code,
    required String fullName,
    required String gender,
    required String dateOfBirth,
    int? age,
    required String phone,
    String? email,
    required Person person,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    NamedRef? insurer,
    String? insurancePolicyNumber,
    String? insuranceExpiryDate,
    String? insuranceCoveragePercent,
    String? bloodGroup,
    String? allergies,
    String? chronicConditions,
    String? familyHistory,
    String? surgicalHistory,
    String? notes,
    bool? hasPortalAccount,
    required int version,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}
