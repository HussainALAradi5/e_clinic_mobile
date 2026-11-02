import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/money.dart';
import '../shared/refs.dart';
import 'prescription.dart';

part 'dispensation.freezed.dart';
part 'dispensation.g.dart';

part 'dispensation_batch_ref.dart';
part 'dispensation_dispensation_item.dart';

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
