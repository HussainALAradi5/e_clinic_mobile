import 'package:e_clinic_core/core.dart';

import '../../models/hr/leave_request.dart';

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
