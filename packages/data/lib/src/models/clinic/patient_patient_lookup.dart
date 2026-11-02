part of 'patient.dart';

/// GET /patients/lookup — who a patient is (no medical data) and whether their file is already open to me.
@freezed
abstract class PatientLookup with _$PatientLookup {
  const factory PatientLookup({
    required String id,
    required String code,
    required String fullName,
    required String gender,
    required int age,
    @Default(false) bool inCare,
  }) = _PatientLookup;

  factory PatientLookup.fromJson(Map<String, dynamic> json) => _$PatientLookupFromJson(json);
}
