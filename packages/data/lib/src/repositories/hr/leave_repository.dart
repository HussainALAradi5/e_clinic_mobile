import 'package:e_clinic_core/core.dart';

import '../../models/hr/leave_request.dart';
import '../../models/hr/leave_type.dart';

class LeaveRepository {
  const LeaveRepository(this._api);

  final ApiClient _api;

  Future<Paged<LeaveRequest>> list(ListQuery query) => _api.list('hr/leaves', query, LeaveRequest.fromJson);

  Future<List<LeaveType>> types() => _api.get('hr/leaves/types', listOf(LeaveType.fromJson));

  /// An employee's days per leave type this [year] (the clinic's current year when null).
  Future<List<LeaveBalance>> balances(String employeeId, {int? year}) =>
      _api.get('hr/leaves/balances/$employeeId', listOf(LeaveBalance.fromJson), query: {'year': year});

  /// A request for the signed-in employee. Types that need a certificate start as a draft; the rest go straight
  /// to the manager.
  Future<LeaveRequest> request({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    bool isHalfDay = false,
    String? reason,
  }) => _api.post(
    'hr/leaves',
    objectOf(LeaveRequest.fromJson),
    body: {
      'leave_type_id': leaveTypeId,
      'start_date': startDate,
      'end_date': endDate,
      'is_half_day': isHalfDay,
      'reason': ?reason,
    },
  );

  /// Sends a draft to the manager (refused while a required certificate is missing).
  Future<LeaveRequest> submit(String id) => _api.patch('hr/leaves/$id/submit', objectOf(LeaveRequest.fromJson));

  Future<LeaveRequest> cancel(String id) => _api.patch('hr/leaves/$id/cancel', objectOf(LeaveRequest.fromJson));

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
