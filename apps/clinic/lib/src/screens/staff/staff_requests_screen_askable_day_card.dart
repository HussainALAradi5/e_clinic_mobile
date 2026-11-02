part of 'staff_requests_screen.dart';

/// A day with late minutes and / or overtime: one coloured button per kind of request it still allows.
class _AskableDayCard extends StatelessWidget {
  const _AskableDayCard({required this.day, required this.onAsk});

  final AskableDay day;
  final void Function(String type) onAsk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = day.attendance;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(ClinicClock.day(a.date), style: theme.textTheme.titleSmall)),
                Text(
                  '${clockTime(a.checkInAt)} – ${clockTime(a.checkOutAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final type in day.types) ...[
              _AskButton(
                late: type == StaffRequestTypes.lateExcuse,
                minutes: type == StaffRequestTypes.lateExcuse ? a.lateMinutes : a.overtimeMinutes,
                onTap: () => onAsk(type),
              ),
              const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }
}
