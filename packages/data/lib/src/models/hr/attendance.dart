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

    /// HR accepted the excuse: these late minutes are not deducted.
    @Default(false) bool lateExcused,

    /// AttendanceStatus wire value (`present`, `late`, `absent` …).
    required String status,
    String? notes,
  }) = _Attendance;

  const Attendance._();

  factory Attendance.fromJson(Map<String, dynamic> json) => _$AttendanceFromJson(json);

  bool get checkedIn => checkInAt != null;

  bool get checkedOut => checkOutAt != null;
}

/// The working hours of the signed-in staff member (`HH:mm`): late after [start]. When they are on a shift, its
/// [code], [name] and [type] (`fixed` / `flexible` — flexible: [start] is the latest time to arrive).
@freezed
abstract class Shift with _$Shift {
  const factory Shift({String? start, String? end, String? code, String? name, String? type}) = _Shift;

  const Shift._();

  bool get flexible => type == 'flexible';

  /// "Morning (SFT-000004) · 08:00 – 16:00", "Office flexi (SFT-000006) · in by 10:00", or just the hours.
  String? get label {
    if (start == null) return null;
    final hours = flexible ? 'in by $start' : '$start – ${end ?? ''}';
    return name == null ? hours : '$name ($code) · $hours';
  }

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

/// GET /hr/attendance/today — today's row (null before checking in) and the shift.
@freezed
abstract class TodayAttendance with _$TodayAttendance {
  const factory TodayAttendance({Attendance? attendance, @Default(Shift()) Shift shift}) = _TodayAttendance;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) => _$TodayAttendanceFromJson(json);
}
