part of 'refs.dart';

/// `{ id, code, full_name, job_title, department? }` — a staff member (attendance, leave).
@freezed
abstract class EmployeeRef with _$EmployeeRef {
  const factory EmployeeRef({
    required String id,
    String? code,
    required String fullName,
    String? jobTitle,
    NamedRef? department,
  }) = _EmployeeRef;

  factory EmployeeRef.fromJson(Map<String, dynamic> json) => _$EmployeeRefFromJson(json);
}
