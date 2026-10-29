import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';

/// `40 min`, `1 h`, `1 h 25 min`.
String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}

/// `2 days, 3 Nov 2026 – 4 Nov 2026` (half days as `2.5 days`).
String leaveDaysLabel(LeaveRequest leave) {
  final days = double.tryParse(leave.totalDays);
  final count = days == null ? leave.totalDays : (days == days.roundToDouble() ? '${days.round()}' : '$days');
  final range = leave.startDate == leave.endDate
      ? ClinicClock.date(leave.startDate)
      : '${ClinicClock.date(leave.startDate)} – ${ClinicClock.date(leave.endDate)}';
  return '$count ${count == '1' ? 'day' : 'days'}, $range';
}
