import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/refs.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
abstract class Specialty with _$Specialty {
  const factory Specialty({required String id, required String name, String? description}) = _Specialty;

  factory Specialty.fromJson(Map<String, dynamic> json) => _$SpecialtyFromJson(json);
}

/// Public doctor profile (patients do not receive phone, email or licence details).
@freezed
abstract class Doctor with _$Doctor {
  const factory Doctor({
    required String id,
    required String fullName,
    required String displayName,
    required String specialtyId,
    NamedRef? specialty,
    ServiceRef? consultationService,
    ServiceRef? followUpService,
    @Default(true) bool isAcceptingPatients,
    bool? isBookable,
    String? title,
    String? bio,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
}
