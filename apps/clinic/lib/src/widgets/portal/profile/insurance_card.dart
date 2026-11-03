import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// The patient's insurance: insurer, policy number, how much it covers and until when.
class InsuranceCard extends StatelessWidget {
  const InsuranceCard({super.key, required this.patient});

  final Patient patient;

  @override
  Widget build(BuildContext context) {
    final p = patient;
    return Card(
      child: FactList(
        facts: [
          (label: 'Insurer', value: p.insurer?.name),
          (label: 'Policy number', value: p.insurancePolicyNumber),
          (
            label: 'Covers',
            value: p.insuranceCoveragePercent == null
                ? null
                : '${double.tryParse(p.insuranceCoveragePercent!)?.round() ?? p.insuranceCoveragePercent} %',
          ),
          (
            label: 'Valid until',
            value: p.insuranceExpiryDate == null ? null : ClinicClock.date(p.insuranceExpiryDate!),
          ),
        ],
      ),
    );
  }
}
