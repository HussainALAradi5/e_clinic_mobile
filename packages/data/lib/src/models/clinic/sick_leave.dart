import 'package:freezed_annotation/freezed_annotation.dart';

part 'sick_leave.freezed.dart';
part 'sick_leave.g.dart';

part 'sick_leave_sick_leave_doctor.dart';

/// Mirror of SickLeaveResource — a sick leave certificate (`SLV-…`) the doctor gave at a visit.
@freezed
abstract class SickLeave with _$SickLeave {
  const factory SickLeave({
    required String id,
    required String code,
    required SickLeaveDoctor doctor,
    required String startDate,
    required String endDate,
    required int days,

    /// Shown to the patient; printed only when [showReason].
    String? reason,
    @Default(false) bool showReason,
    String? notes,
    required DateTime issuedAt,
    @Default(false) bool isCancelled,
    String? cancelReason,
  }) = _SickLeave;

  factory SickLeave.fromJson(Map<String, dynamic> json) => _$SickLeaveFromJson(json);
}
