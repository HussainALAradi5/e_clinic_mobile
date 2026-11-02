part of 'patient.dart';

@freezed
abstract class Nationality with _$Nationality {
  const factory Nationality({required String code, required String nationality}) = _Nationality;

  factory Nationality.fromJson(Map<String, dynamic> json) => _$NationalityFromJson(json);
}
