import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/patient_providers.dart';
import '../staff_paths.dart';
import '../widgets/patients/emergency_access_sheet.dart';
import '../widgets/patients/patient_tile.dart';

/// `/clinic/patients` — find a patient file by name, file number or mobile (newest files first).
class PatientsScreen extends ConsumerWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(patientSearchProvider);
    final access = ref.watch(accessProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient files'),
        actions: [
          // Clinicians who see only their own patients can open another one in an emergency.
          if (access.can('patients.read_own & patients.view_medical') && !access.can('patients.read_all'))
            IconButton(
              tooltip: 'Emergency access',
              icon: const Icon(Icons.emergency_outlined),
              onPressed: () async {
                final id = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const EmergencyAccessSheet(),
                );
                if (id != null && context.mounted) unawaited(context.push(StaffPaths.patient(id)));
              },
            ),
        ],
      ),
      body: Column(
        children: [
          SearchField(hint: 'Name, file number or mobile', onChanged: ref.read(patientSearchProvider.notifier).set),
          Expanded(
            child: InfiniteList<Patient>(
              reloadKey: search,
              load: (page) => ref.read(patientRepositoryProvider).list(patientsQuery(search, page)),
              empty: EmptyState(
                icon: Icons.person_search_rounded,
                title: search.isEmpty ? 'No patient files yet' : 'No match',
                message: search.isEmpty ? null : 'Try part of the name, the file number or the mobile.',
              ),
              itemBuilder: (context, patient, _) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: PatientTile(patient: patient, onTap: () => context.push(StaffPaths.patient(patient.id))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
