import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/patient_text.dart';

/// A patient file on a list: initials, name, file number · age · mobile, and a warning mark for allergies.
class PatientTile extends StatelessWidget {
  const PatientTile({super.key, required this.patient, required this.onTap, this.trailing});

  final Patient patient;
  final VoidCallback onTap;

  /// Defaults to a chevron.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allergic = patient.allergies?.trim().isNotEmpty ?? false;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(initials(patient.fullName)),
        ),
        title: Row(
          children: [
            Flexible(child: Text(patient.fullName, overflow: TextOverflow.ellipsis)),
            if (allergic) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: PatientText.allergies,
                child: Icon(Icons.warning_amber_rounded, size: 18, color: scheme.error),
              ),
            ],
          ],
        ),
        subtitle: Text([patient.code, if (patient.age != null) '${patient.age} y', patient.phone].join(' · ')),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
