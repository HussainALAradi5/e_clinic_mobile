part of 'doctor.dart';

@freezed
abstract class Specialty with _$Specialty {
  const factory Specialty({required String id, required String name, String? description}) = _Specialty;

  factory Specialty.fromJson(Map<String, dynamic> json) => _$SpecialtyFromJson(json);
}
