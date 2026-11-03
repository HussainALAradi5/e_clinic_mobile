import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../patients/patient_tile.dart';
import 'patient_picker_sheet.dart';

/// The patient being booked: a "Find the patient" button, or their tile (tap to change); both open the search.
class PatientField extends StatelessWidget {
  const PatientField({super.key, required this.patient, required this.onChanged});

  final Patient? patient;
  final ValueChanged<Patient> onChanged;

  Future<void> _choose(BuildContext context) async {
    final picked = await pickPatient(context);
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: switch (patient) {
        null => OutlinedButton.icon(
          onPressed: () => _choose(context),
          icon: const Icon(Icons.person_search_rounded),
          label: const Text('Find the patient'),
        ),
        final p => PatientTile(
          patient: p,
          onTap: () => _choose(context),
          trailing: const Icon(Icons.swap_horiz_rounded),
        ),
      },
    );
  }
}
