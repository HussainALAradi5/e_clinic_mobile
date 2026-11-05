import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/portal/profile_text.dart';

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
          (label: ProfileText.insurer, value: p.insurer?.name),
          (label: ProfileText.policyNumber, value: p.insurancePolicyNumber),
          (
            label: ProfileText.covers,
            value: p.insuranceCoveragePercent == null
                ? null
                : '${double.tryParse(p.insuranceCoveragePercent!)?.round() ?? p.insuranceCoveragePercent} %',
          ),
          (
            label: ProfileText.validUntil,
            value: p.insuranceExpiryDate == null ? null : ClinicClock.date(p.insuranceExpiryDate!),
          ),
        ],
      ),
    );
  }
}
