import 'package:e_clinic_core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

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

/// Mirror of PrescriptionResource — pending → in progress (partly dispensed) → completed / cancelled.
@freezed
abstract class Prescription with _$Prescription {
  const factory Prescription({
    required String id,
    required String code,

    /// Staff only (the portal leaves it out).
    PatientRef? patient,
    PersonRef? doctor,
    @JsonKey(unknownEnumValue: GenericStatus.unknown) required GenericStatus status,
    required String validUntil,
    String? notes,
    DateTime? createdAt,
    @Default([]) List<PrescriptionItem> items,
  }) = _Prescription;

  const Prescription._();

  factory Prescription.fromJson(Map<String, dynamic> json) => _$PrescriptionFromJson(json);

  /// Still to collect at the pharmacy: not fully dispensed, cancelled or expired.
  bool get collectable => GenericStatus.open.contains(status) && validUntil.compareTo(ClinicClock.today()) >= 0;
}
