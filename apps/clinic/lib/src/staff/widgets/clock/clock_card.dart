import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/staff_providers.dart';
import '../../utils/clock_location.dart';
import '../../utils/formatters.dart';

/// One-tap clock in / out with today's state. The server accepts it only from the clinic network and works out
/// late arrival and overtime from the shift.
class ClockCard extends ConsumerWidget {
  const ClockCard({super.key, this.large = false});

  /// The full clock page: bigger text, the day's punches listed.
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayClockProvider);
    return today.when(
      loading: () => SkeletonList(count: 1, height: large ? 220 : 120),
      error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(todayClockProvider)),
      data: (t) => _ClockBody(today: t, large: large),
    );
  }
}

class _ClockBody extends ConsumerWidget {
  const _ClockBody({required this.today, required this.large});

  final TodayAttendance today;
  final bool large;

  String _time(DateTime? instant) {
    if (instant == null) return '—';
    final l = ClinicClock.local(instant);
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final row = today.attendance;
    final shift = today.shift;
    final repository = ref.read(attendanceRepositoryProvider);

    final notIn = row == null || !row.checkedIn;
    final working = row != null && row.checkedIn && !row.checkedOut;

    final String title;
    final String detail;
    if (row == null || notIn) {
      title = 'Not checked in';
      detail = shift.start == null
          ? 'Check in when you arrive.'
          : shift.flexible
          ? '${shift.name}: arrive by ${shift.start}.'
          : '${shift.name ?? 'Your shift'} starts at ${shift.start}.';
    } else if (working) {
      title = 'Checked in at ${_time(row.checkInAt)}';
      detail = [
        if (row.lateMinutes > 0) '${formatMinutes(row.lateMinutes)} late',
        if (shift.end != null) 'Shift ends at ${shift.end}',
      ].join(' · ');
    } else {
      final worked = row.workedMinutes;
      title = 'Done for today';
      detail =
          '${_time(row.checkInAt)} – ${_time(row.checkOutAt)}'
          '${worked == null ? '' : ' · ${formatMinutes(worked)} worked'}';
    }

    final Widget? button = switch ((notIn, working)) {
      (true, _) => AppButton(
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
      ),
      (_, true) => AppButton(
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
      ),
      _ => null,
    };

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
        if (row != null) ...[
          const SectionHeader('Today'),
          Card(
            child: FactList(
              facts: [
                (label: 'Checked in', value: row.checkInAt == null ? null : _time(row.checkInAt)),
                (label: 'Checked out', value: row.checkOutAt == null ? null : _time(row.checkOutAt)),
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
          ),
        ],
      ],
    );
  }
}
