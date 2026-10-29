import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/refs.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

/// Mirror of LeaveRequestResource.
@freezed
abstract class LeaveRequest with _$LeaveRequest {
  const factory LeaveRequest({
    required String id,
    required String code,
    required String employeeId,
    EmployeeRef? employee,
    NamedRef? leaveType,
    required String startDate,
    required String endDate,

    /// Working days as a decimal string (`"2.5"`).
    required String totalDays,
    @Default(false) bool isHalfDay,
    String? reason,

    /// ApprovalStatus: `draft` (waits for a certificate), `pending`, `approved`, `rejected` or `cancelled`.
    required String status,
    String? reviewNotes,
    int? attachmentsCount,
    DateTime? createdAt,
  }) = _LeaveRequest;

  const LeaveRequest._();

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => _$LeaveRequestFromJson(json);

  bool get isDraft => status == 'draft';

  /// The requester may still withdraw it (the server allows draft and pending only).
  bool get cancellable => status == 'draft' || status == 'pending';
}
