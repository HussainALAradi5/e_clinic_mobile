part of 'prescription.dart';

@freezed
abstract class MedicationRef with _$MedicationRef {
  const factory MedicationRef({
    required String id,
    String? code,
    required String name,
    String? unit,

    /// Barcode on the pack (GTIN), matched when the pharmacist scans it.
    String? gtin,

    /// Controlled drugs need a second member of staff as witness.
    @Default(false) bool isControlled,
  }) = _MedicationRef;

  factory MedicationRef.fromJson(Map<String, dynamic> json) => _$MedicationRefFromJson(json);
}
