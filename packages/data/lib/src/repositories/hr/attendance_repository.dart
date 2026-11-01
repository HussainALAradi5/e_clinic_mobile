import 'package:e_clinic_core/core.dart';
import '../../models/hr/attendance.dart';

/// Where the phone is when clocking (degrees) and how precise that is (metres).
typedef ClockPosition = ({double latitude, double longitude, double? accuracy});

/// Attendance — the staff member's own day, and overtime approval for managers.
class AttendanceRepository {
  const AttendanceRepository(this._api);

  final ApiClient _api;

  Future<TodayAttendance> today() => _api.get('hr/attendance/today', objectOf(TodayAttendance.fromJson));

  /// At the clinic only: the server accepts its network, or [position] inside the clinic geofence when one is set.
  Future<Attendance> checkIn({ClockPosition? position}) =>
      _api.post('hr/attendance/check-in', objectOf(Attendance.fromJson), body: _body(position));

  Future<Attendance> checkOut({ClockPosition? position}) =>
      _api.post('hr/attendance/check-out', objectOf(Attendance.fromJson), body: _body(position));

  static Map<String, Object>? _body(ClockPosition? p) =>
      p == null ? null : {'latitude': p.latitude, 'longitude': p.longitude, 'accuracy': ?p.accuracy};

  Future<Paged<Attendance>> list(ListQuery query) => _api.list('hr/attendance', query, Attendance.fromJson);

  Future<Attendance> approveOvertime(String id) =>
      _api.patch('hr/attendance/$id/approve-overtime', objectOf(Attendance.fromJson));
}
