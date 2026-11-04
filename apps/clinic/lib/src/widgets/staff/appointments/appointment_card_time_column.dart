part of 'appointment_card.dart';

/// Start time (bold, tabular) over end time, in a fixed-width column.
class _TimeColumn extends StatelessWidget {
  const _TimeColumn({required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 56,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ClinicClock.wallTime(visit.startTime),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            ClinicClock.wallTime(visit.endTime),
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
