import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/clinic/clinical_order_type.dart';
import '../../enums/shared/generic_status.dart';
import '../shared/refs.dart';

part 'clinical_order.freezed.dart';
part 'clinical_order.g.dart';

part 'clinical_order_attachment.dart';
part 'clinical_order_signed_link.dart';

/// Mirror of ClinicalOrderResource — a test, scan or referral. Patients see the report once it is completed.
@freezed
abstract class ClinicalOrder with _$ClinicalOrder {
  const factory ClinicalOrder({
    required String id,
    required String code,
    @JsonKey(unknownEnumValue: ClinicalOrderType.unknown) required ClinicalOrderType type,
    required String description,

    /// Staff only (the portal leaves it out — it is the patient themself).
    PatientRef? patient,
    PersonRef? orderingDoctor,
    String? bodyPart,

    /// Only with `patients.view_medical`.
    String? clinicalNotes,

    /// `medium`, `high` or `urgent` (TreatmentPriority).
    @Default('medium') String priority,
    @JsonKey(unknownEnumValue: GenericStatus.unknown) required GenericStatus status,

    /// Statuses the order may move to next (drives the work-list buttons; the server re-checks).
    @JsonKey(unknownEnumValue: GenericStatus.unknown) @Default([]) List<GenericStatus> allowedTransitions,
    NamedRef? room,
    PersonRef? performer,
    DateTime? startedAt,
    DateTime? completedAt,
    String? report,
    PersonRef? reporter,
    bool? isAbnormal,
    String? cancellationReason,
    DateTime? createdAt,
    @Default([]) List<Attachment> attachments,
  }) = _ClinicalOrder;

  const ClinicalOrder._();

  factory ClinicalOrder.fromJson(Map<String, dynamic> json) => _$ClinicalOrderFromJson(json);

  bool canMoveTo(GenericStatus next) => allowedTransitions.contains(next);

  bool get isUrgent => priority == 'urgent';
}
