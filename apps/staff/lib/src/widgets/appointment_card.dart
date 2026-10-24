import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/visit_actions.dart';
import '../staff_paths.dart';

/// A booking on a staff list: time, patient, type / room / provider, status, and the next step as a button
/// (other steps under ⋯). Tapping opens the booking.
class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({super.key, required this.visit, this.showProvider = true, this.showDate = false});

  final Appointment visit;
  final bool showProvider;

  /// For bookings that may not be today (a scanned code).
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final actions = VisitAction.available(visit, ref.watch(accessProvider));
    final primary = VisitAction.primary(actions);
    final others = actions.where((a) => a != primary).toList();
    final kind = visit.type == AppointmentType.treatmentSession && visit.sessionNumber != null
        ? 'Session ${visit.sessionNumber}'
        : catalog.label('AppointmentType', visit.type);
    final details = [
      kind,
      if (visit.room != null) visit.room!.name,
      if (showProvider && visit.provider != null) visit.provider!.fullName,
    ].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(StaffPaths.appointment(visit.id)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 56,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.startTime,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(visit.endTime, style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDate)
                          Text(
                            ClinicClock.relativeDay(visit.scheduledDate),
                            style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary),
                          ),
                        Text(visit.patientName, style: theme.textTheme.titleMedium),
                        if (visit.patient?.code != null)
                          Text(
                            visit.patient!.code!,
                            style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        const SizedBox(height: 4),
                        Text(details, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            StatusChip(enumName: 'AppointmentStatus', value: visit.status),
                            if (visitTiming(visit) case final timing?) _TimingLabel(timing: timing),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (others.isNotEmpty)
                    PopupMenuButton<VisitAction>(
                      tooltip: 'More actions',
                      onSelected: (action) => VisitActions.runFromMenu(context, ref, action, visit),
                      itemBuilder: (_) => [
                        for (final action in others)
                          PopupMenuItem(
                            value: action,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(action.icon),
                              title: Text(action.label),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              if (primary != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: VisitActionButton(
                    action: primary,
                    visit: visit,
                    expand: true,
                    variant: primary == VisitAction.checkIn ? ButtonVariant.filled : ButtonVariant.tonal,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// How the visit is running against the clock today: late (more than 10 minutes past the start and not checked
/// in, as on the web front-desk board) or waiting since check-in. Null when there is nothing to say.
({String text, bool late})? visitTiming(Appointment visit, {DateTime? now}) {
  if (visit.scheduledDate != ClinicClock.today()) return null;
  final clock = now ?? ClinicClock.now();
  final minutesNow = clock.hour * 60 + clock.minute;
  if (visit.status == AppointmentStatus.pending || visit.status == AppointmentStatus.confirmed) {
    final [h, m] = visit.startTime.split(':').map(int.parse).toList();
    final late = minutesNow - (h * 60 + m);
    return late > lateAfterMinutes ? (text: 'Late ${_minutes(late)}', late: true) : null;
  }
  final checkedIn = visit.checkedInAt;
  if (visit.status == AppointmentStatus.checkedIn && checkedIn != null) {
    final local = ClinicClock.local(checkedIn);
    final waiting = minutesNow - (local.hour * 60 + local.minute);
    return waiting >= 1 ? (text: 'Waiting ${_minutes(waiting)}', late: false) : null;
  }
  return null;
}

/// A patient counts as late this many minutes after the start.
const lateAfterMinutes = 10;

String _minutes(int minutes) => minutes < 60 ? '$minutes min' : '${minutes ~/ 60} h ${minutes % 60} min';

class _TimingLabel extends StatelessWidget {
  const _TimingLabel({required this.timing});

  final ({String text, bool late}) timing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = timing.late ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(timing.late ? Icons.schedule_rounded : Icons.hourglass_bottom_rounded, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          timing.text,
          style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
