part of 'patient.dart';

/// One emergency / additional contact of a patient (up to three): a phone, the name and relation optional.
@freezed
abstract class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({String? name, String? relation, required String phone}) = _EmergencyContact;

  const EmergencyContact._();

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);

  /// Most a patient keeps (server: EmergencyContactData::MAX).
  static const max = 3;

  /// "Sara Yousif (Sister) +973 3600 1122".
  String get line => [name, if (relation != null) '($relation)', phone].whereType<String>().join(' ');
}
