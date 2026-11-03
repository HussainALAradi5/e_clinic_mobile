part of 'clock_card.dart';

/// Check in (when not in yet) or check out (while working), with the result as a message.
class _ClockButton extends ConsumerWidget {
  const _ClockButton({required this.today});

  final TodayAttendance today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final row = today.attendance;
    final shift = today.shift;
    final repository = ref.read(attendanceRepositoryProvider);
    if (row == null || !row.checkedIn) {
      return AppButton(
        label: 'Check in',
        icon: Icons.login_rounded,
        expand: true,
        onPressed: () async {
          final row = await repository.checkIn(position: await clockPosition());
          ref.read(todayClockProvider.notifier).replace(row);
          final late = row.lateMinutes;
          if (context.mounted) {
            late > 0
                ? AppSnack.info(context, 'Checked in — ${formatMinutes(late)} late for ${shift.name ?? 'your shift'}.')
                : AppSnack.success(context, 'Checked in on time. Have a good shift.');
          }
        },
      );
    }
    return AppButton(
      label: 'Check out',
      icon: Icons.logout_rounded,
      variant: ButtonVariant.tonal,
      expand: true,
      confirm: const ConfirmConfig(
        title: 'Check out now?',
        message: 'Staying 15 minutes or more past your shift is sent for overtime approval.',
        confirmLabel: 'Check out',
      ),
      onPressed: () async {
        final row = await repository.checkOut(position: await clockPosition());
        ref.read(todayClockProvider.notifier).replace(row);
        final overtime = row.overtimeMinutes;
        if (context.mounted) {
          AppSnack.success(
            context,
            overtime > 0
                ? 'Checked out — ${formatMinutes(overtime)} overtime, sent for approval.'
                : 'Checked out. See you next time.',
          );
        }
      },
    );
  }
}
