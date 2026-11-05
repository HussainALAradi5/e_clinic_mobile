import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/leave_text.dart';

/// The kinds of leave as chips, and for the chosen one what it needs: a certificate, notice days ahead.
class LeaveTypePicker extends StatelessWidget {
  const LeaveTypePicker({super.key, required this.types, required this.selected, required this.onSelected});

  final List<LeaveType> types;
  final LeaveType? selected;
  final ValueChanged<LeaveType> onSelected;

  @override
  Widget build(BuildContext context) {
    final type = selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in types)
                ChoiceChip(label: Text(t.name), selected: type?.id == t.id, onSelected: (_) => onSelected(t)),
            ],
          ),
        ),
        if (type != null && type.requiresAttachment)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: InfoNote(icon: Icons.attach_file_rounded, text: LeaveText.needsCertificate),
          ),
        if (type != null && type.minNoticeDays > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: InfoNote(icon: Icons.schedule_rounded, text: LeaveText.noticeDays(type.minNoticeDays)),
          ),
      ],
    );
  }
}
