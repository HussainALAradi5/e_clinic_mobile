import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The care team's medical history of a patient: allergies, chronic conditions, family and surgical history.
/// Returns the saved file (null when closed).
class MedicalHistorySheet extends ConsumerStatefulWidget {
  const MedicalHistorySheet({super.key, required this.patient});

  final Patient patient;

  @override
  ConsumerState<MedicalHistorySheet> createState() => _MedicalHistorySheetState();
}

class _MedicalHistorySheetState extends ConsumerState<MedicalHistorySheet> {
  late final _allergies = TextEditingController(text: widget.patient.allergies);
  late final _chronic = TextEditingController(text: widget.patient.chronicConditions);
  late final _family = TextEditingController(text: widget.patient.familyHistory);
  late final _surgical = TextEditingController(text: widget.patient.surgicalHistory);

  @override
  void dispose() {
    for (final c in [_allergies, _chronic, _family, _surgical]) {
      c.dispose();
    }
    super.dispose();
  }

  static String? _value(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final saved = await ref
        .read(patientRepositoryProvider)
        .updateMedicalHistory(
          widget.patient.id,
          version: widget.patient.version,
          allergies: _value(_allergies),
          chronicConditions: _value(_chronic),
          familyHistory: _value(_family),
          surgicalHistory: _value(_surgical),
        );
    if (mounted) Navigator.pop(context, saved);
  }

  Widget _field(TextEditingController c, String label, {String? hint, int lines = 2}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      minLines: 1,
      maxLines: lines,
      maxLength: 2000,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(labelText: label, hintText: hint, counterText: ''),
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Medical history', style: Theme.of(context).textTheme.titleLarge),
          Text(widget.patient.fullName, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          _field(_allergies, 'Allergies', hint: 'e.g. Penicillin'),
          _field(_chronic, 'Chronic conditions', lines: 3),
          _field(_family, 'Family history', hint: 'e.g. Father: type 2 diabetes', lines: 4),
          _field(_surgical, 'Surgical history', lines: 3),
          AppButton(label: 'Save', icon: Icons.check_rounded, expand: true, onPressed: _save),
        ],
      ),
    ),
  );
}
