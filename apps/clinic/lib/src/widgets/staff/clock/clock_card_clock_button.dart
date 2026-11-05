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
        label: ClockText.checkIn,
        icon: Icons.login_rounded,
        expand: true,
        onPressed: () async {
          final row = await repository.checkIn(position: await clockPosition());
          ref.read(todayClockProvider.notifier).replace(row);
          final late = row.lateMinutes;
          if (context.mounted) {
            late > 0
                ? AppSnack.info(context, ClockText.checkedInLate(formatMinutes(late), shift.name))
                : AppSnack.success(context, ClockText.onTime);
          }
        },
      );
    }
    return AppButton(
      label: ClockText.checkOut,
      icon: Icons.logout_rounded,
      variant: ButtonVariant.tonal,
      expand: true,
      confirm: const ConfirmConfig(
        title: ClockText.checkOutNow,
        message: ClockText.overtimeWarning,
        confirmLabel: ClockText.checkOut,
      ),
      onPressed: () async {
        final row = await repository.checkOut(position: await clockPosition());
        ref.read(todayClockProvider.notifier).replace(row);
        final overtime = row.overtimeMinutes;
        if (context.mounted) {
          AppSnack.success(
            context,
            overtime > 0
                ? ClockText.checkedOutOvertime(formatMinutes(overtime))
                : ClockText.checkedOutDone,
          );
        }
      },
    );
  }
}
