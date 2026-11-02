import 'package:e_clinic_core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

part 'prescription_medication_ref.dart';
part 'prescription_prescription_item.dart';

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
