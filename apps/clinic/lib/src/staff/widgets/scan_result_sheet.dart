import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/staff_providers.dart';
import 'appointment_card.dart';

/// What a scanned code points to: a booking (with its next step, usually *Check in*), a patient card (with their
/// bookings today), or the record's key facts.
Future<void> showScanResultSheet(BuildContext context, ScanResult result) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: switch (result.entity) {
          'appointment' => _BookingResult(result: result),
          'person' => _PersonResult(result: result),
          _ => _RecordResult(result: result),
        },
      ),
    ),
  ),
);

class _BookingResult extends ConsumerWidget {
  const _BookingResult({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Title(title: 'Booking', code: result.code),
      AsyncBody(
        value: ref.watch(appointmentProvider(result.id)),
        onRetry: () => ref.invalidate(appointmentProvider(result.id)),
        loading: const SkeletonList(count: 1, height: 160),
        data: (visit) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (visit.scheduledDate != ClinicClock.today())
              InfoNote(
                icon: Icons.event_busy_outlined,
                text: 'This booking is for ${ClinicClock.relativeDay(visit.scheduledDate)}, not today.',
              ),
            AppointmentCard(visit: visit, showDate: true),
          ],
        ),
      ),
    ],
  );
}

class _PersonResult extends ConsumerWidget {
  const _PersonResult({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final born = result.text('date_of_birth');
    final gender = result.text('gender');
    final canSchedule = ref.watch(canSeeScheduleProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(title: result.text('full_name') ?? 'Person', code: result.code),
        Card(
          child: FactList(
            facts: [
              (label: 'File number', value: result.code),
              (label: 'Date of birth', value: born == null ? null : ClinicClock.date(born)),
              (label: 'Gender', value: gender == null ? null : catalog.label('Gender', gender)),
            ],
          ),
        ),
        if (canSchedule) ...[
          const SectionHeader('Bookings today'),
          AsyncBody(
            value: ref.watch(patientTodayProvider(result.code)),
            onRetry: () => ref.invalidate(patientTodayProvider(result.code)),
            loading: const SkeletonList(count: 1, height: 140),
            data: (visits) => visits.isEmpty
                ? const InfoNote(icon: Icons.event_available_outlined, text: 'No booking today for this person.')
                : Column(
                    children: [
                      for (final visit in visits)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppointmentCard(visit: visit),
                        ),
                    ],
                  ),
          ),
        ],
      ],
    );
  }
}

class _RecordResult extends ConsumerWidget {
  const _RecordResult({required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = [
      for (final MapEntry(:key, :value) in result.summary.entries)
        if (key != 'code' && value != null && value is! Map && value is! List)
          (label: humanise(key), value: _value(key, '$value')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Title(title: humanise(result.entity), code: result.code),
        if (facts.isNotEmpty) Card(child: FactList(facts: facts)),
        const InfoNote(
          icon: Icons.verified_outlined,
          text: 'The code is genuine. Open the record on the website for everything else.',
        ),
      ],
    );
  }

  /// Dates and instants read as clinic dates; everything else as sent (statuses humanised).
  static String _value(String key, String value) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return ClinicClock.date(value);
    final instant = DateTime.tryParse(value);
    if (instant != null && value.contains('T')) return ClinicClock.dateTime(instant);
    if (key == 'status' || key == 'type' || key == 'kind' || key == 'method') return humanise(value);
    return value;
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.title, required this.code});

  final String title;
  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Row(
        children: [
          Icon(Icons.qr_code_2_rounded, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          Text(code, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
