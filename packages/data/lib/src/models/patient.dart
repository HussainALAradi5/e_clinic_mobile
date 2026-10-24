import 'package:freezed_annotation/freezed_annotation.dart';

import 'refs.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

@freezed
abstract class Nationality with _$Nationality {
  const factory Nationality({required String code, required String nationality}) = _Nationality;

  factory Nationality.fromJson(Map<String, dynamic> json) => _$NationalityFromJson(json);
}

@freezed
abstract class Address with _$Address {
  const factory Address({required String id, String? formatted}) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}

/// The person behind a patient file (name, ID, contact); `version` locks it on update.
@freezed
abstract class Person with _$Person {
  const factory Person({
    required String id,
    required int version,
    String? nationalId,
    Nationality? nationality,
    Address? address,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

/// Mirror of PatientResource as the portal returns it (no medical fields).
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
    required int version,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}
