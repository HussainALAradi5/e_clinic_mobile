import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';

/// `40 min`, `1 h`, `1 h 25 min`.
String formatMinutes(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m min';
  return m == 0 ? '$h h' : '$h h $m min';
}

/// `08:27` on the clinic clock, `—` when there is no time.
String clockTime(DateTime? instant) {
  if (instant == null) return '—';
  final l = ClinicClock.local(instant);
  return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

/// A medicine quantity as people write it: `2`, `2.5`, `0.25` (no trailing zeros).
String formatQuantity(num quantity) {
  if (quantity == quantity.roundToDouble()) return '${quantity.round()}';
  return quantity.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
}

/// A dispensing unit for a quantity: `1 tablet`, `20 tablets`, `5 ml` (units come singular from the server).
String unitLabel(String? unit, num quantity) {
  if (unit == null || unit.isEmpty) return '';
  return quantity == 1 || unit == 'ml' ? unit : '${unit}s';
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
