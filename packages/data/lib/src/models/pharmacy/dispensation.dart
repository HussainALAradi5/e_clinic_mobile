import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/money.dart';
import '../shared/refs.dart';
import 'prescription.dart';

part 'dispensation.freezed.dart';
part 'dispensation.g.dart';

/// The stock batch a line came from (first expiry first out).
@freezed
abstract class BatchRef with _$BatchRef {
  const factory BatchRef({required String id, String? code, required String batchNumber, required String expiryDate}) =
      _BatchRef;

  factory BatchRef.fromJson(Map<String, dynamic> json) => _$BatchRefFromJson(json);
}

/// One medicine handed over or given.
@freezed
abstract class DispensationItem with _$DispensationItem {
  const factory DispensationItem({
    required String id,
    required MedicationRef medication,
    BatchRef? batch,
    required String quantity,
    Money? lineTotal,
  }) = _DispensationItem;

  factory DispensationItem.fromJson(Map<String, dynamic> json) => _$DispensationItemFromJson(json);
}

/// Mirror of DispensationResource — medicine that left stock for a patient (take-home or given in a session).
@freezed
abstract class Dispensation with _$Dispensation {
  const factory Dispensation({
    required String id,
    required String code,

    /// `take_home` or `administered`.
    required String kind,

    /// `completed` or `cancelled` (GenericStatus).
    required String status,
    PatientRef? patient,
    String? prescriptionId,
    PersonRef? dispensedBy,
    PersonRef? witness,
    required DateTime dispensedAt,
    String? notes,
    String? cancellationReason,
    @Default([]) List<DispensationItem> items,
  }) = _Dispensation;

  factory Dispensation.fromJson(Map<String, dynamic> json) => _$DispensationFromJson(json);
}
