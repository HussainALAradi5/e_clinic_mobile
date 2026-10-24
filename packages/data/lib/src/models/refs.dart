import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'refs.freezed.dart';
part 'refs.g.dart';

/// `{ id, full_name }` — a doctor, performer or reporter shown by name.
@freezed
abstract class PersonRef with _$PersonRef {
  const factory PersonRef({required String id, required String fullName, String? jobTitle}) = _PersonRef;

  factory PersonRef.fromJson(Map<String, dynamic> json) => _$PersonRefFromJson(json);
}

/// `{ id, code, full_name, phone? }` — the patient of a booking or a refund (staff app).
@freezed
abstract class PatientRef with _$PatientRef {
  const factory PatientRef({required String id, String? code, required String fullName, String? phone}) =
      _PatientRef;

  factory PatientRef.fromJson(Map<String, dynamic> json) => _$PatientRefFromJson(json);
}

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

/// `{ id, code?, name }` — a room, specialty, service or insurer.
@freezed
abstract class NamedRef with _$NamedRef {
  const factory NamedRef({required String id, String? code, required String name}) = _NamedRef;

  factory NamedRef.fromJson(Map<String, dynamic> json) => _$NamedRefFromJson(json);
}

/// A price-list service with its price.
@freezed
abstract class ServiceRef with _$ServiceRef {
  const factory ServiceRef({required String id, String? code, required String name, required Money price}) =
      _ServiceRef;

  factory ServiceRef.fromJson(Map<String, dynamic> json) => _$ServiceRefFromJson(json);
}
