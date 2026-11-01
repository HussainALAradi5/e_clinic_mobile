import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// Medical, insurance and contact details of a patient file (medical lines only when the server sent them).
class PatientFacts extends StatelessWidget {
  const PatientFacts({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final emergency = [
      p.emergencyContactName,
      if (p.emergencyContactRelation != null) '(${p.emergencyContactRelation})',
      p.emergencyContactPhone,
    ].whereType<String>().join(' ');
    final insurance = p.insurer == null
        ? 'Self-paying'
        : [
            p.insurer!.name,
            if (p.insuranceCoveragePercent != null) '${p.insuranceCoveragePercent}% covered',
          ].join(' · ');
    return FactList(
      facts: [
        (label: 'Blood group', value: p.bloodGroup == 'unknown' ? null : p.bloodGroup),
        (label: 'Chronic conditions', value: p.chronicConditions),
        (label: 'Date of birth', value: ClinicClock.date(p.dateOfBirth)),
        (label: 'ID number', value: p.person.nationalId),
        (label: 'Email', value: p.email),
        (label: 'Address', value: p.person.address?.formatted),
        (label: 'Insurance', value: insurance),
        (label: 'Policy', value: p.insurancePolicyNumber),
        (
          label: 'Insurance expires',
          value: p.insuranceExpiryDate == null ? null : ClinicClock.date(p.insuranceExpiryDate!),
        ),
        (label: 'Emergency contact', value: emergency.isEmpty ? null : emergency),
        (label: 'Front-desk notes', value: p.notes),
      ],
    );
  }
}
