import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/scan_text.dart';
import '../../../controllers/staff/staff_providers.dart';
import '../appointments/appointment_card.dart';
import 'person_scan_result.dart';
import 'record_scan_result.dart';
import 'scan_result_title.dart';

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
          'appointment' => BookingScanResult(result: result),
          'person' => PersonScanResult(result: result),
          _ => RecordScanResult(result: result),
        },
      ),
    ),
  ),
);

class BookingScanResult extends ConsumerWidget {
  const BookingScanResult({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ScanResultTitle(title: ScanText.booking, code: result.code),
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
