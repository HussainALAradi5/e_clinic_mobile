import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/booking_text.dart';
import '../../../controllers/staff/patient_providers.dart';
import '../patients/patient_tile.dart';

/// Searches patient files and returns the one tapped (null when closed).
Future<Patient?> pickPatient(BuildContext context) => showModalBottomSheet<Patient>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const FractionallySizedBox(heightFactor: 0.9, child: _PatientPicker()),
);

class _PatientPicker extends ConsumerStatefulWidget {
  const _PatientPicker();

  @override
  ConsumerState<_PatientPicker> createState() => _PatientPickerState();
}

class _PatientPickerState extends ConsumerState<_PatientPicker> {
  var _search = '';

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(
          children: [
            Expanded(child: Text(BookingText.chooseThePatient, style: Theme.of(context).textTheme.titleLarge)),
            IconButton(
              tooltip: CommonText.close,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      SearchField(hint: CommonText.patientSearch, autofocus: true, onChanged: (v) => setState(() => _search = v)),
      Expanded(
        child: InfiniteList<Patient>(
          reloadKey: _search,
          load: (page) => ref.read(patientRepositoryProvider).list(patientsQuery(_search, page)),
          empty: const EmptyState(icon: Icons.person_search_rounded, title: BookingText.noMatch),
          itemBuilder: (context, patient, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: PatientTile(
              patient: patient,
              trailing: const Icon(Icons.add_circle_outline_rounded),
              onTap: () => Navigator.pop(context, patient),
            ),
          ),
        ),
      ),
    ],
  );
}
