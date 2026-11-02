import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/money.dart';
import '../shared/refs.dart';
import 'attendance.dart';

part 'staff_request.freezed.dart';
part 'staff_request.g.dart';

part 'staff_request_askable_day.dart';
part 'staff_request_staff_request_day.dart';
part 'staff_request_staff_request_details.dart';
part 'staff_request_staff_request_types.dart';

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
