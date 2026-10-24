import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';
import 'refs.dart';

part 'approvals.freezed.dart';
part 'approvals.g.dart';

/// Mirror of RefundResource (what an approver needs to decide).
@freezed
abstract class Refund with _$Refund {
  const factory Refund({
    required String id,
    required String code,
    PatientRef? patient,
    required Money amount,

    /// PaymentMethod wire value.
    required String method,
    String? reason,

    /// ApprovalStatus wire value (`pending`, `approved` …).
    required String status,
    PersonRef? requestedBy,
    DateTime? createdAt,
  }) = _Refund;

  factory Refund.fromJson(Map<String, dynamic> json) => _$RefundFromJson(json);
}

/// Mirror of ExpenseResource.
@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String code,

    /// ExpenseCategory wire value.
    required String category,
    String? payeeName,
    String? description,
    required Money amount,
    required String expenseDate,
    required String status,
    PersonRef? submittedBy,
    DateTime? createdAt,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
}

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
    required String status,
    int? attachmentsCount,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => _$LeaveRequestFromJson(json);
}
