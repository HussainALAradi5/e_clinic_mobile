import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/refs.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

/// Mirror of AttendanceResource — one staff member's day.
@freezed
abstract class Attendance with _$Attendance {
  const factory Attendance({
    required String id,
    required String employeeId,
    EmployeeRef? employee,
    required String date,
    DateTime? checkInAt,
    DateTime? checkOutAt,
    int? workedMinutes,
    @Default(0) int lateMinutes,
    @Default(0) int overtimeMinutes,
    bool? overtimeApproved,

    /// AttendanceStatus wire value (`present`, `late`, `absent` …).
    required String status,
    String? notes,
  }) = _Attendance;

  const Attendance._();

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

  bool get checkedIn => checkInAt != null;

  bool get checkedOut => checkOutAt != null;
}

/// The working hours of the signed-in staff member (`HH:mm`).
@freezed
abstract class Shift with _$Shift {
  const factory Shift({String? start, String? end}) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

/// GET /hr/attendance/today — today's row (null before checking in) and the shift.
@freezed
abstract class TodayAttendance with _$TodayAttendance {
  const factory TodayAttendance({Attendance? attendance, @Default(Shift()) Shift shift}) = _TodayAttendance;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) => _$TodayAttendanceFromJson(json);
}
