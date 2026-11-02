part of 'patient.dart';

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
