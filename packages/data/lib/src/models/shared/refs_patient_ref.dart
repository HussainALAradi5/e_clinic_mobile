part of 'refs.dart';

/// `{ id, code, full_name, phone? }` — the patient of a booking or a refund (staff app).
@freezed
abstract class PatientRef with _$PatientRef {
  const factory PatientRef({required String id, String? code, required String fullName, String? phone}) = _PatientRef;

  factory PatientRef.fromJson(Map<String, dynamic> json) => _$PatientRefFromJson(json);
}
