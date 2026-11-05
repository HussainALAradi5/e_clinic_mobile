part of 'clock_card.dart';

class _ClockBody extends StatelessWidget {
  const _ClockBody({required this.today, required this.large});

  final TodayAttendance today;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final row = today.attendance;
    final shift = today.shift;

    final notIn = row == null || !row.checkedIn;
    final working = row != null && row.checkedIn && !row.checkedOut;

    final String title;
    final String detail;
    if (row == null || notIn) {
      title = ClockText.notCheckedIn;
      detail = shift.start == null
          ? ClockText.checkInOnArrival
          : shift.flexible
          ? '${shift.name}: arrive by ${shift.start}.'
          : '${shift.name ?? 'Your shift'} starts at ${shift.start}.';
    } else if (working) {
      title = ClockText.checkedInAt(clockTime(row.checkInAt));
      detail = [
        if (row.lateMinutes > 0) ClockText.minutesLate(formatMinutes(row.lateMinutes)),
        if (shift.end != null) ClockText.shiftEndsAt(shift.end!),
      ].join(' · ');
    } else {
      final worked = row.workedMinutes;
      title = ClockText.doneForToday;
      detail =
          '${clockTime(row.checkInAt)} – ${clockTime(row.checkOutAt)}'
          '${worked == null ? '' : ' · ${formatMinutes(worked)} worked'}';
    }

    final button = notIn || working ? _ClockButton(today: today) : null;

    final icon = Container(
      width: large ? 64 : 44,
      height: large ? 64 : 44,
      decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
      child: Icon(
        row?.checkedOut ?? false ? Icons.check_rounded : Icons.schedule_rounded,
        color: scheme.onPrimaryContainer,
        size: large ? 32 : 24,
      ),
    );
    final text = Column(
      crossAxisAlignment: large ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(title, style: large ? theme.textTheme.headlineSmall : theme.textTheme.titleMedium),
        if (detail.isNotEmpty)
          Text(
            detail,
            textAlign: large ? TextAlign.center : TextAlign.start,
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        // Present / late / absent / on leave … coloured as everywhere else.
        if (row != null) ...[const SizedBox(height: 8), StatusChip(enumName: 'AttendanceStatus', value: row.status)],
      ],
    );

    if (!large) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 16),
                  Expanded(child: text),
                ],
              ),
              if (button != null) ...[const SizedBox(height: 12), button],
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                icon,
                const SizedBox(height: 16),
                text,
                if (button != null) ...[const SizedBox(height: 24), button],
              ],
            ),
          ),
        ),
        if (row != null) ...[const SectionHeader(ClockText.today), _TodayFacts(row: row, shift: shift)],
      ],
    );
  }
}
