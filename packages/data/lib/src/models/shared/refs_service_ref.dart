part of 'refs.dart';

/// A price-list service with its price.
@freezed
abstract class ServiceRef with _$ServiceRef {
  const factory ServiceRef({required String id, String? code, required String name, required Money price}) =
      _ServiceRef;

  factory ServiceRef.fromJson(Map<String, dynamic> json) => _$ServiceRefFromJson(json);
}
