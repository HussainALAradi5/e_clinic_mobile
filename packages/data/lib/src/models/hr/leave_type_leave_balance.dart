part of 'leave_type.dart';

/// Mirror of LeaveBalanceResource — one type's days for a year (decimal strings).
@freezed
abstract class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    required String id,
    required int year,
    required LeaveType leaveType,
    required String entitledDays,
    required String usedDays,
    required String pendingDays,

    /// Null for types without a quota (unpaid leave).
    String? remainingDays,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);
}
