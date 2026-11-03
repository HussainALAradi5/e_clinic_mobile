import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

/// What the visit is for: a new problem (consultation) or a follow-up.
class VisitTypePicker extends StatelessWidget {
  const VisitTypePicker({super.key, required this.selected, required this.onChanged});

  static const _types = [(AppointmentType.consultation, 'New problem'), (AppointmentType.followUp, 'Follow-up')];

  final AppointmentType selected;
  final ValueChanged<AppointmentType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<AppointmentType>(
        showSelectedIcon: false,
        segments: [for (final (value, label) in _types) ButtonSegment(value: value, label: Text(label))],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
