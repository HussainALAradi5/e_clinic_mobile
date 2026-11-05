import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/routes/staff_paths.dart';
import '../../constants/billing/wallet_text.dart';
import '../../constants/staff/patient_detail_text.dart';
import '../../controllers/staff/patient_providers.dart';
import '../../widgets/billing/wallet_card.dart';
import '../../widgets/staff/appointments/appointment_card.dart';
import '../../widgets/staff/patients/medical_alert_card.dart';
import '../../widgets/staff/patients/medical_history_sheet.dart';
import '../../widgets/staff/patients/patient_facts.dart';
import '../../widgets/staff/patients/patient_timeline.dart';

part 'patient_detail_screen_upcoming.dart';

/// `/clinic/patients/:id` — a patient file: allergies first, details, coming visits and history; *Book a visit*
/// for those who may book.
class PatientDetailScreen extends ConsumerWidget {
  const PatientDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = ref.watch(patientProvider(id));
    final access = ref.watch(accessProvider);
    final canBook = access.can('appointments.create');
    return Scaffold(
      appBar: AppBar(
        title: Text(file.value?.code ?? PatientDetailText.title),
        actions: [
          if (file.value != null && access.can('records.write & patients.view_medical'))
            IconButton(
              tooltip: PatientDetailText.medicalHistory,
              icon: const Icon(Icons.medical_information_outlined),
              onPressed: () async {
                final saved = await showModalBottomSheet<Patient>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => MedicalHistorySheet(patient: file.value!),
                );
                if (saved != null) {
                  ref.invalidate(patientProvider(id));
                  if (context.mounted) AppSnack.success(context, PatientDetailText.historySaved);
                }
              },
            ),
        ],
      ),
      body: AsyncBody(
        value: file,
        onRetry: () => ref.invalidate(patientProvider(id)),
        data: (patient) => RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(patientProvider(id))
              ..invalidate(patientTimelineProvider(id))
              ..invalidate(patientUpcomingProvider(id));
            await ref.read(patientProvider(id).future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ProfileHeader(
                  name: patient.fullName,
                  lines: [
                    [patient.code, if (patient.age case final age?) PatientDetailText.age(age)].join(' · '),
                    patient.phone,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatusChip(enumName: 'Gender', value: patient.gender),
                    if (patient.person.nationality case final n?) FlagBadge(countryCode: n.code, label: n.nationality),
                  ],
                ),
              ),
              if (patient.allergies?.trim().isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: MedicalAlertCard(allergies: patient.allergies!),
                ),
              const SectionHeader(PatientDetailText.details),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: PatientFacts(patient: patient),
              ),
              if (access.can('wallet.read_all')) ...[
                const SectionHeader(WalletText.title),
                WalletCard(patientId: id, manage: true),
              ],
              if (access.can('appointments.read_all | appointments.read_own')) ...[
                const SectionHeader(PatientDetailText.comingVisits),
                _UpcomingVisits(patientId: id),
              ],
              const SectionHeader(PatientDetailText.history),
              ref
                  .watch(patientTimelineProvider(id))
                  .when(
                    loading: () => const SkeletonList(count: 3, height: 56),
                    error: (error, _) =>
                        ErrorState(error: error, onRetry: () => ref.invalidate(patientTimelineProvider(id))),
                    data: (entries) => PatientTimeline(
                      entries: entries,
                      canOpenOrders: access.can('orders.read_all | orders.read_own'),
                    ),
                  ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: canBook && file.hasValue
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton.icon(
                onPressed: () => context.push(StaffPaths.bookFor(id)),
                icon: const Icon(Icons.event_available_rounded),
                label: const Text(PatientDetailText.book),
              ),
            )
          : null,
    );
  }
}
