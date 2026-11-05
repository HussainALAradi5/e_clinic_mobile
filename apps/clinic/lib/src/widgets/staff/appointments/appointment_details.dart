import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/appointment_text.dart';
import '../../../controllers/staff/staff_providers.dart';

class AppointmentDetails extends ConsumerWidget {
  const AppointmentDetails({super.key, required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final patient = visit.patient;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(appointmentProvider(visit.id));
        await ref.read(appointmentProvider(visit.id).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(visit.patientName, style: theme.textTheme.headlineSmall),
          Text(
            '${ClinicClock.relativeDay(visit.scheduledDate)} · ${ClinicClock.timeRange(visit.startTime, visit.endTime)}',
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(enumName: 'AppointmentStatus', value: visit.status),
          ),
          const SectionHeader(AppointmentText.booking),
          Card(
            child: FactList(
              facts: [
                (
                  label: AppointmentText.type,
                  value: visit.sessionNumber == null
                      ? catalog.label('AppointmentType', visit.type)
                      : '${catalog.label('AppointmentType', visit.type)} · session ${visit.sessionNumber}',
                ),
                (label: AppointmentText.provider, value: visit.provider?.fullName),
                (label: CommonText.room, value: visit.room?.name),
                (label: AppointmentText.service, value: visit.billableService?.name),
                (label: CommonText.reason, value: visit.reason),
                (
                  label: CommonText.checkedIn,
                  value: visit.checkedInAt == null ? null : ClinicClock.dateTime(visit.checkedInAt!),
                ),
                (
                  label: CommonText.started,
                  value: visit.startedAt == null ? null : ClinicClock.dateTime(visit.startedAt!),
                ),
                (label: CommonText.cancelledBecause, value: visit.cancellationReason),
              ],
            ),
          ),
          if (patient != null) ...[
            const SectionHeader(CommonText.patient),
            Card(
              child: FactList(
                facts: [
                  (label: CommonText.fileNumber, value: patient.code),
                  (label: CommonText.mobile, value: patient.phone),
                ],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
            child: Text(
              AppointmentText.workspaceHint,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
