import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// From / to dates for a list: "Any date", or the chosen days with a clear button. Opens the phone's date range
/// picker (two years back to one year ahead); `null` is any date.
class DateRangeChip extends StatelessWidget {
  const DateRangeChip({super.key, required this.range, required this.onChanged, this.label = 'Any date'});

  final DateTimeRange? range;
  final ValueChanged<DateTimeRange?> onChanged;
  final String label;

  Future<void> _pick(BuildContext context) async {
    final today = ClinicClock.parse(ClinicClock.today());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: today.subtract(const Duration(days: 730)),
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: range,
      helpText: 'From – to',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final range = this.range;
    final text = range == null
        ? label
        : '${ClinicClock.date(ClinicClock.isoDate(range.start))} – ${ClinicClock.date(ClinicClock.isoDate(range.end))}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InputChip(
          avatar: const Icon(Icons.date_range_rounded, size: 18),
          label: Text(text),
          selected: range != null,
          showCheckmark: false,
          onPressed: () => _pick(context),
          onDeleted: range == null ? null : () => onChanged(null),
        ),
      ),
    );
  }
}
