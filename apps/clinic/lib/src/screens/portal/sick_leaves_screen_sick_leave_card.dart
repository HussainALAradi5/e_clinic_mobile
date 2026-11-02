part of 'sick_leaves_screen.dart';

class _SickLeaveCard extends StatelessWidget {
  const _SickLeaveCard({required this.leave});

  final SickLeave leave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(leave.code, style: muted?.copyWith(fontFamily: 'monospace')),
                const Spacer(),
                Text('Issued ${ClinicClock.dateTime(leave.issuedAt)}', style: muted),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${leave.days} ${leave.days == 1 ? 'day' : 'days'} off',
              style: theme.textTheme.titleLarge?.copyWith(
                decoration: leave.isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),
            Text(
              '${ClinicClock.date(leave.startDate)} – ${ClinicClock.date(leave.endDate)}',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            FactList(
              facts: [
                (label: 'Doctor', value: leave.doctor.fullName),
                (label: 'Reason', value: leave.reason),
                (label: 'Notes', value: leave.notes),
              ],
            ),
            if (leave.isCancelled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InfoNote(
                  icon: Icons.block_rounded,
                  text: 'Cancelled by the doctor: ${leave.cancelReason ?? ''}',
                ),
              )
            else ...[
              const SizedBox(height: 12),
              AppButton(
                label: 'Show the code',
                icon: Icons.qr_code_2_rounded,
                variant: ButtonVariant.tonal,
                expand: true,
                onPressed: () => PortalActions.showSickLeaveCode(context, leave),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
