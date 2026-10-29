import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/staff_providers.dart';

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
            '${ClinicClock.relativeDay(visit.scheduledDate)} · ${visit.startTime}–${visit.endTime}',
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(enumName: 'AppointmentStatus', value: visit.status),
          ),
          const SectionHeader('Booking'),
          Card(
            child: FactList(
              facts: [
                (
                  label: 'Type',
                  value: visit.sessionNumber == null
                      ? catalog.label('AppointmentType', visit.type)
                      : '${catalog.label('AppointmentType', visit.type)} · session ${visit.sessionNumber}',
                ),
                (label: 'With', value: visit.provider?.fullName),
                (label: 'Room', value: visit.room?.name),
                (label: 'Service', value: visit.billableService?.name),
                (label: 'Reason', value: visit.reason),
                (
                  label: 'Checked in',
                  value: visit.checkedInAt == null ? null : ClinicClock.dateTime(visit.checkedInAt!),
                ),
                (label: 'Started', value: visit.startedAt == null ? null : ClinicClock.dateTime(visit.startedAt!)),
                (label: 'Cancelled because', value: visit.cancellationReason),
              ],
            ),
          ),
          if (patient != null) ...[
            const SectionHeader('Patient'),
            Card(
              child: FactList(
                facts: [(label: 'File number', value: patient.code), (label: 'Mobile', value: patient.phone)],
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
            child: Text(
              'Notes, orders and prescriptions are in the visit workspace on the clinic website.',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
