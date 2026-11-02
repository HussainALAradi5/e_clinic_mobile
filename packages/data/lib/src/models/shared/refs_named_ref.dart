part of 'refs.dart';

/// `{ id, code?, name }` — a room, specialty, service or insurer.
@freezed
abstract class NamedRef with _$NamedRef {
  const factory NamedRef({required String id, String? code, required String name}) = _NamedRef;

  factory NamedRef.fromJson(Map<String, dynamic> json) => _$NamedRefFromJson(json);
}
