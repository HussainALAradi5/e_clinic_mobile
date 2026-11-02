part of 'dispensation.dart';

/// The stock batch a line came from (first expiry first out).
@freezed
abstract class BatchRef with _$BatchRef {
  const factory BatchRef({required String id, String? code, required String batchNumber, required String expiryDate}) =
      _BatchRef;

  factory BatchRef.fromJson(Map<String, dynamic> json) => _$BatchRefFromJson(json);
}
