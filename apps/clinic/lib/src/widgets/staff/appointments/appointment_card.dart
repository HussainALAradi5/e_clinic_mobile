import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/staff_paths.dart';
import '../../../controllers/staff/visit_actions.dart';
import '../../../utilities/staff/visit_timing.dart';
import '../visits/visit_action_button.dart';
import 'timing_label.dart';

/// A booking on a staff list: time, patient, type / room / provider, status, and the next step as a button
/// (other steps under ⋯). Tapping opens the booking.
class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({
    super.key,
    required this.visit,
    this.showProvider = true,
    this.showDate = false,
    this.readOnly = false,
  });

  final Appointment visit;
  final bool showProvider;

  /// For bookings that may not be today (a scanned code).
  final bool showDate;

  /// No steps (an offline copy): the card only shows the booking.
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final actions = readOnly ? const <VisitAction>[] : VisitAction.available(visit, ref.watch(accessProvider));
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
                            if (visitTiming(visit) case final timing?) TimingLabel(timing: timing),
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
