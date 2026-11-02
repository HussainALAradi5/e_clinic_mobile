part of 'sick_leave.dart';

@freezed
abstract class SickLeaveDoctor with _$SickLeaveDoctor {
  const factory SickLeaveDoctor({required String id, required String fullName, String? jobTitle}) = _SickLeaveDoctor;

  factory SickLeaveDoctor.fromJson(Map<String, dynamic> json) => _$SickLeaveDoctorFromJson(json);
}
