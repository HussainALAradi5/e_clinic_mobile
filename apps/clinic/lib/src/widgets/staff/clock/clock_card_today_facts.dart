part of 'clock_card.dart';

/// The day's punches on the full clock page: in, out, late, overtime (and whether it is approved), the shift.
class _TodayFacts extends StatelessWidget {
  const _TodayFacts({required this.row, required this.shift});

  final Attendance row;
  final Shift shift;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FactList(
        facts: [
          (label: 'Checked in', value: row.checkInAt == null ? null : clockTime(row.checkInAt)),
          (label: 'Checked out', value: row.checkOutAt == null ? null : clockTime(row.checkOutAt)),
          (label: 'Late', value: row.lateMinutes > 0 ? formatMinutes(row.lateMinutes) : null),
          (
            label: 'Overtime',
            value: row.overtimeMinutes > 0
                ? '${formatMinutes(row.overtimeMinutes)}'
                      '${row.overtimeApproved ?? false ? ' (approved)' : ' (waiting for approval)'}'
                : null,
          ),
          (label: 'Shift', value: shift.label),
        ],
      ),
    );
  }
}
