import 'package:freezed_annotation/freezed_annotation.dart';

import '../shared/refs.dart';

part 'attendance.freezed.dart';
part 'attendance.g.dart';

part 'attendance_shift.dart';
part 'attendance_today_attendance.dart';

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
