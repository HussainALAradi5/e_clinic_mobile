import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/scan_text.dart';
import '../../../controllers/staff/staff_providers.dart';
import '../appointments/appointment_card.dart';
import 'scan_result_title.dart';

class PersonScanResult extends ConsumerWidget {
  const PersonScanResult({super.key, required this.result});

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
        ScanResultTitle(title: result.text('full_name') ?? ScanText.person, code: result.code),
        Card(
          child: FactList(
            facts: [
              (label: CommonText.fileNumber, value: result.code),
              (label: CommonText.dateOfBirth, value: born == null ? null : ClinicClock.date(born)),
              (label: ScanText.gender, value: gender == null ? null : catalog.label('Gender', gender)),
            ],
          ),
        ),
        if (canSchedule) ...[
          const SectionHeader(ScanText.bookingsToday),
          AsyncBody(
            value: ref.watch(patientTodayProvider(result.code)),
            onRetry: () => ref.invalidate(patientTodayProvider(result.code)),
            loading: const SkeletonList(count: 1, height: 140),
            data: (visits) => visits.isEmpty
                ? const InfoNote(icon: Icons.event_available_outlined, text: ScanText.noBookingToday)
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
