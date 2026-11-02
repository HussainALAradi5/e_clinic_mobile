part of 'patient.dart';

@freezed
abstract class Address with _$Address {
  const factory Address({required String id, String? formatted}) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}
