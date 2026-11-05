import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/patient_text.dart';

/// Break the glass: find a patient outside my care by file number or national ID, confirm the person, give the
/// reason, and their file opens for the shift. Every use is recorded and the admins are told.
/// Returns the patient id to open (null when closed).
class EmergencyAccessSheet extends ConsumerStatefulWidget {
  const EmergencyAccessSheet({super.key});

  @override
  ConsumerState<EmergencyAccessSheet> createState() => _EmergencyAccessSheetState();
}

class _EmergencyAccessSheetState extends ConsumerState<EmergencyAccessSheet> {
  final _find = TextEditingController();
  final _reason = TextEditingController();
  PatientLookup? _found;
  var _searched = false;

  @override
  void dispose() {
    _find.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final value = _find.text.trim();
    if (value.isEmpty) throw const ActionCancelled();
    // A file number looks like PRS-000123; anything else is taken as a national ID.
    final byCode = value.toUpperCase().startsWith('PRS-');
    final found = await ref
        .read(patientRepositoryProvider)
        .lookup(code: byCode ? value : null, nationalId: byCode ? null : value);
    setState(() {
      _found = found;
      _searched = true;
    });
  }

  Future<void> _open() async {
    final patient = _found!;
    if (!patient.inCare) {
      if (_reason.text.trim().length < 10) {
        throw const ApiException(status: 422, code: ErrorCodes.validationFailed, message: PatientText.reasonTooShort);
      }
      await ref.read(patientRepositoryProvider).emergencyAccess(patient.id, _reason.text.trim());
      if (mounted) AppSnack.info(context, PatientText.emergencyGranted(patient.fullName));
    }
    if (mounted) Navigator.pop(context, patient.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _found;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.emergency_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(PatientText.emergencyAccess, style: theme.textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            const InfoNote(icon: Icons.policy_outlined, text: PatientText.emergencyNote),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _find,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: PatientText.lookupLabel,
                      hintText: PatientText.lookupHint,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: PatientText.find,
                  icon: Icons.search_rounded,
                  variant: ButtonVariant.tonal,
                  onPressed: _lookup,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (p != null) ...[
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: const Icon(Icons.person_rounded),
                  title: Text(p.fullName),
                  subtitle: Text('${p.code} · ${p.age} y'),
                  trailing: StatusChip(enumName: 'Gender', value: p.gender),
                ),
              ),
              const SizedBox(height: 12),
              if (p.inCare)
                const InfoNote(icon: Icons.check_circle_outline, text: PatientText.alreadyInCare)
              else
                TextField(
                  controller: _reason,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: CommonText.reason, hintText: PatientText.reasonHint),
                ),
              const SizedBox(height: 8),
              AppButton(
                label: p.inCare ? PatientText.openTheFile : PatientText.openInEmergency,
                icon: p.inCare ? Icons.folder_open_rounded : Icons.lock_open_rounded,
                lock: ButtonLock.once,
                expand: true,
                onPressed: _open,
              ),
            ] else if (_searched)
              Text(PatientText.noPatientFound, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
