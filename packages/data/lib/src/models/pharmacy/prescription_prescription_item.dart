part of 'prescription.dart';

/// A prescribed medicine with how to take it.
@freezed
abstract class PrescriptionItem with _$PrescriptionItem {
  const factory PrescriptionItem({
    required String id,
    required MedicationRef medication,
    required String dose,
    required String frequency,
    required String route,
    required int durationDays,
    required String quantity,

    /// Sent with a single prescription (not in lists); null = nothing dispensed yet.
    String? dispensedQuantity,
    String? remainingQuantity,
    String? instructions,
  }) = _PrescriptionItem;

  const PrescriptionItem._();

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) => _$PrescriptionItemFromJson(json);

  /// What is still to hand over (the whole quantity when nothing was dispensed yet).
  double get outstanding => double.tryParse(remainingQuantity ?? quantity) ?? 0;
}
