import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';

part 'appointment_fee.freezed.dart';
part 'appointment_fee.g.dart';

/// Mirror of AppointmentFeeResource: a fee for a missed or late-cancelled visit, charged on the patient's invoice
/// or waived (with who and why).
@freezed
abstract class AppointmentFee with _$AppointmentFee {
  const factory AppointmentFee({
    required String id,
    required String code,

    /// AppointmentFeeType wire value (`no_show`, `late_cancel`).
    required String type,

    /// AppointmentFeeStatus wire value (`charged`, `waived`).
    required String status,
    required Money amount,
    required FeeVisit appointment,
    String? waiverReason,
    DateTime? createdAt,
  }) = _AppointmentFee;

  const AppointmentFee._();

  factory AppointmentFee.fromJson(Map<String, dynamic> json) => _$AppointmentFeeFromJson(json);

  bool get waived => status == 'waived';
}

/// The missed visit of a fee.
@freezed
abstract class FeeVisit with _$FeeVisit {
  const factory FeeVisit({required String id, required String code, required String scheduledDate, String? startTime}) =
      _FeeVisit;

  factory FeeVisit.fromJson(Map<String, dynamic> json) => _$FeeVisitFromJson(json);
}
