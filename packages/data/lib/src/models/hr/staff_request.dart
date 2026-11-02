import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/money.dart';
import '../shared/refs.dart';
import 'attendance.dart';

part 'staff_request.freezed.dart';
part 'staff_request.g.dart';

/// StaffRequestType wire values: excuse a late arrival, or pay a day's overtime.
abstract final class StaffRequestTypes {
  static const lateExcuse = 'late_excuse';
  static const overtime = 'overtime';
}

/// Mirror of StaffRequestResource — a late excuse or overtime request about one attendance day.
@freezed
abstract class StaffRequest with _$StaffRequest {
  const factory StaffRequest({
    required String id,
    required String code,

    /// StaffRequestType wire value ([StaffRequestTypes]).
    required String type,

    /// ApprovalStatus wire value (`pending`, `approved`, `rejected`, `cancelled`).
    required String status,
    required String employeeId,
    EmployeeRef? employee,
    StaffRequestDay? attendance,

    /// Late or overtime minutes: live while pending, as decided afterwards.
    @Default(0) int minutes,
    StaffRequestDetails? details,
    String? reason,
    PersonRef? reviewedBy,
    DateTime? reviewedAt,
    String? reviewReason,
    DateTime? createdAt,
  }) = _StaffRequest;

  const StaffRequest._();

  factory StaffRequest.fromJson(Map<String, dynamic> json) => _$StaffRequestFromJson(json);

  bool get isLate => type == StaffRequestTypes.lateExcuse;

  bool get isPending => status == 'pending';
}

/// The day a request is about, as attendance measured it.
@freezed
abstract class StaffRequestDay with _$StaffRequestDay {
  const factory StaffRequestDay({
    required String id,
    required String date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    @Default(0) int workedMinutes,
  }) = _StaffRequestDay;

  factory StaffRequestDay.fromJson(Map<String, dynamic> json) => _$StaffRequestDayFromJson(json);
}

/// Snapshot kept on the request: the minutes and, for overtime, the rate per hour and amount; for a late arrival,
/// what it would cost if not excused.
@freezed
abstract class StaffRequestDetails with _$StaffRequestDetails {
  const factory StaffRequestDetails({@Default(0) int minutes, String? rate, Money? amount}) = _StaffRequestDetails;

  factory StaffRequestDetails.fromJson(Map<String, dynamic> json) => _$StaffRequestDetailsFromJson(json);
}

/// GET hr/requests/askable — a recent day of mine and the kinds of request it still allows.
@freezed
abstract class AskableDay with _$AskableDay {
  const factory AskableDay({required Attendance attendance, @Default([]) List<String> types}) = _AskableDay;

  factory AskableDay.fromJson(Map<String, dynamic> json) => _$AskableDayFromJson(json);
}
