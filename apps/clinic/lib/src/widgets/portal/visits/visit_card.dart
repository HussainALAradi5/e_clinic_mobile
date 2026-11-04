import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/portal/visit_text.dart';
import '../../../controllers/portal/portal_actions.dart';
import '../../common/timing_edge.dart';

/// A visit: date block, time and doctor, status; check-in code and cancel while it is ahead.
class VisitCard extends ConsumerWidget {
  const VisitCard({super.key, required this.visit, this.onChanged});

  final Appointment visit;
  final ValueChanged<Appointment>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final upcoming =
        AppointmentStatus.upcoming.contains(visit.status) && visit.scheduledDate.compareTo(ClinicClock.today()) >= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: TimingEdge(
        timing: visit.timing,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DateBlock(date: visit.scheduledDate, highlighted: upcoming),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ClinicClock.relativeDay(visit.scheduledDate)} · ${ClinicClock.wallTime(visit.startTime)}',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(visit.doctorName, style: theme.textTheme.bodyMedium),
                        Text(
                          catalog.label('AppointmentType', visit.type),
                          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (visit.timing != VisitTiming.unknown)
                              StatusChip(enumName: 'VisitTiming', value: visit.timing),
                            StatusChip(enumName: 'AppointmentStatus', value: visit.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (visit.status == AppointmentStatus.pending && upcoming) ...[
                const SizedBox(height: 12),
                Text(
                  'Waiting for the clinic to confirm.',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              if (visit.cancellationReason != null && visit.status == AppointmentStatus.cancelled) ...[
                const SizedBox(height: 12),
                Text(
                  'Cancelled: ${visit.cancellationReason}',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              if (upcoming) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => PortalActions.showVisitCode(context, visit),
                      icon: const Icon(Icons.qr_code_2_rounded),
                      label: const Text('Check-in code'),
                    ),
                    const Spacer(),
                    if (visit.status.cancellable && !visit.patientCanChange)
                      Text(VisitText.callReception, style: Theme.of(context).textTheme.bodySmall)
                    else if (visit.status.cancellable)
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: scheme.error),
                        onPressed: () async {
                          final updated = await PortalActions.cancelVisit(context, ref, visit);
                          if (updated != null) onChanged?.call(updated);
                        },
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
