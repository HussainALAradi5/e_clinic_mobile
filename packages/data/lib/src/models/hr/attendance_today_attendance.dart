part of 'attendance.dart';

/// GET /hr/attendance/today — today's row (null before checking in) and the shift.
@freezed
abstract class TodayAttendance with _$TodayAttendance {
  const factory TodayAttendance({Attendance? attendance, @Default(Shift()) Shift shift}) = _TodayAttendance;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) => _$TodayAttendanceFromJson(json);
}
