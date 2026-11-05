import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/leave_text.dart';

/// The days off: a button that opens the range picker (from 30 days back, for sick leave asked for afterwards, to
/// a year ahead) and shows the chosen days, and "Half day" when it is one day.
class LeaveDaysField extends StatelessWidget {
  const LeaveDaysField({
    super.key,
    required this.range,
    required this.halfDay,
    required this.onRange,
    required this.onHalfDay,
  });

  final DateTimeRange? range;
  final bool halfDay;
  final ValueChanged<DateTimeRange> onRange;
  final ValueChanged<bool> onHalfDay;

  static bool isOneDay(DateTimeRange? range) => range != null && DateUtils.isSameDay(range.start, range.end);

  Future<void> _pick(BuildContext context) async {
    final today = ClinicClock.parse(ClinicClock.today());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: range,
      helpText: LeaveText.daysOff,
    );
    if (picked != null) onRange(picked);
  }

  @override
  Widget build(BuildContext context) {
    final range = this.range;
    final oneDay = isOneDay(range);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: const Icon(Icons.date_range_rounded),
            label: Text(
              range == null
                  ? LeaveText.chooseTheDays
                  : oneDay
                  ? ClinicClock.day(ClinicClock.isoDate(range.start))
                  : '${ClinicClock.date(ClinicClock.isoDate(range.start))} – ${ClinicClock.date(ClinicClock.isoDate(range.end))}',
            ),
          ),
        ),
        if (oneDay)
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: halfDay,
            onChanged: onHalfDay,
            title: const Text(LeaveText.halfDay),
          ),
      ],
    );
  }
}
