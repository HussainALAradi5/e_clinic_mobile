import 'package:e_clinic_core/core.dart';

import '../models/approvals.dart';
import '../models/attendance.dart';
import '../models/scan_result.dart';

/// QR codes & barcodes — one endpoint resolves any signed code to its record.
class CodeRepository {
  const CodeRepository(this._api);

  final ApiClient _api;

  /// `purpose`: `identify`, `check_in`, `verify_document` or `sample_label`. A forged or unknown code → 422.
  Future<ScanResult> scan(String payload, {String purpose = 'identify'}) => _api.post(
    'codes/scan',
    objectOf(ScanResult.fromJson),
    body: {'payload': payload.trim(), 'purpose': purpose},
  );
}

/// Attendance — the staff member's own day, and overtime approval for managers.
class AttendanceRepository {
  const AttendanceRepository(this._api);

  final ApiClient _api;

  Future<TodayAttendance> today() => _api.get('hr/attendance/today', objectOf(TodayAttendance.fromJson));

  /// Only from the clinic network (the server checks the address).
  Future<Attendance> checkIn() => _api.post('hr/attendance/check-in', objectOf(Attendance.fromJson));

  Future<Attendance> checkOut() => _api.post('hr/attendance/check-out', objectOf(Attendance.fromJson));

  Future<Paged<Attendance>> list(ListQuery query) => _api.list('hr/attendance', query, Attendance.fromJson);

  Future<Attendance> approveOvertime(String id) =>
      _api.patch('hr/attendance/$id/approve-overtime', objectOf(Attendance.fromJson));
}

/// Refunds — someone other than the requester approves or rejects.
class RefundRepository {
  const RefundRepository(this._api);

  final ApiClient _api;

  Future<Paged<Refund>> list(ListQuery query) => _api.list('billing/refunds', query, Refund.fromJson);

  Future<Refund> approve(String id) => _api.post('billing/refunds/$id/approve', objectOf(Refund.fromJson));

  Future<Refund> reject(String id, String reason) =>
      _api.post('billing/refunds/$id/reject', objectOf(Refund.fromJson), body: {'reason': reason});
}

class ExpenseRepository {
  const ExpenseRepository(this._api);

  final ApiClient _api;

  Future<Paged<Expense>> list(ListQuery query) => _api.list('finance/expenses', query, Expense.fromJson);

  Future<Expense> approve(String id) => _api.post('finance/expenses/$id/approve', objectOf(Expense.fromJson));

  Future<Expense> reject(String id, String reason) =>
      _api.post('finance/expenses/$id/reject', objectOf(Expense.fromJson), body: {'reason': reason});
}

class LeaveRepository {
  const LeaveRepository(this._api);

  final ApiClient _api;

  Future<Paged<LeaveRequest>> list(ListQuery query) => _api.list('hr/leaves', query, LeaveRequest.fromJson);

  /// Booked visits on those days stop the approval ([ErrorCodes.scheduleHasAppointments]) unless
  /// [cancelAffected] — then they are cancelled and the patients told.
  Future<LeaveRequest> approve(String id, {String? notes, bool cancelAffected = false}) => _api.patch(
    'hr/leaves/$id/approve',
    objectOf(LeaveRequest.fromJson),
    body: {'notes': ?notes, 'cancel_affected': cancelAffected},
  );

  Future<LeaveRequest> reject(String id, String notes) =>
      _api.patch('hr/leaves/$id/reject', objectOf(LeaveRequest.fromJson), body: {'notes': notes});
}
