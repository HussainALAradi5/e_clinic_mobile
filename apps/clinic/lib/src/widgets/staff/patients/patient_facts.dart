import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/patient_text.dart';

/// Medical, insurance and contact details of a patient file (medical lines only when the server sent them).
class PatientFacts extends StatelessWidget {
  const PatientFacts({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final emergency = p.emergencyContacts.map((c) => c.line).join('\n');
    final insurance = p.insurer == null
        ? PatientText.selfPaying
        : [
            p.insurer!.name,
            if (p.insuranceCoveragePercent != null) '${p.insuranceCoveragePercent}% covered',
          ].join(' · ');
    return FactList(
      facts: [
        (label: PatientText.bloodGroup, value: p.bloodGroup == 'unknown' ? null : p.bloodGroup),
        (label: PatientText.chronicConditions, value: p.chronicConditions),
        (label: PatientText.familyHistory, value: p.familyHistory),
        (label: PatientText.surgicalHistory, value: p.surgicalHistory),
        (label: CommonText.dateOfBirth, value: ClinicClock.date(p.dateOfBirth)),
        (label: CommonText.idNumber, value: p.person.nationalId),
        (label: CommonText.email, value: p.email),
        (label: CommonText.address, value: p.person.address?.formatted),
        (label: PatientText.insurance, value: insurance),
        (label: PatientText.policy, value: p.insurancePolicyNumber),
        (
          label: PatientText.insuranceExpires,
          value: p.insuranceExpiryDate == null ? null : ClinicClock.date(p.insuranceExpiryDate!),
        ),
        (label: CommonText.emergencyContacts, value: emergency.isEmpty ? null : emergency),
        (label: PatientText.frontDeskNotes, value: p.notes),
      ],
    );
  }
}
