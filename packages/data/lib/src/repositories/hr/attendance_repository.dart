import 'package:e_clinic_core/core.dart';
import '../../models/hr/attendance.dart';

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
