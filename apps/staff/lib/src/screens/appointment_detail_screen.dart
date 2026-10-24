import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/staff_providers.dart';
import '../application/visit_actions.dart';

/// `/clinic/appointments/:id` — one booking: who, when, where, its status, and every step this user may take
/// (the main one as the bottom button).
class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(appointmentProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(booking.value?.code ?? 'Booking')),
      body: AsyncBody(
        value: booking,
        onRetry: () => ref.invalidate(appointmentProvider(id)),
        data: (visit) => _Details(visit: visit),
      ),
      bottomNavigationBar: booking.hasValue ? _Actions(visit: booking.value!) : null,
    );
  }
}

class _Details extends ConsumerWidget {
  const _Details({required this.visit});

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

class _Actions extends ConsumerWidget {
  const _Actions({required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = VisitAction.available(visit, ref.watch(accessProvider));
    if (actions.isEmpty) return const SizedBox.shrink();
    final primary = VisitAction.primary(actions);
    final others = actions.where((a) => a != primary).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            for (final action in others) ...[
              VisitActionButton(action: action, visit: visit, variant: ButtonVariant.outlined),
              const SizedBox(width: 8),
            ],
            if (primary != null)
              Expanded(
                child: VisitActionButton(action: primary, visit: visit, expand: true),
              ),
          ],
        ),
      ),
    );
  }
}
