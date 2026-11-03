import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

/// How the patient asked for the visit: at the desk or by phone.
class BookingSourcePicker extends StatelessWidget {
  const BookingSourcePicker({super.key, required this.selected, required this.onChanged});

  static const _sources = [
    (AppointmentSource.walkIn, 'At the desk', Icons.storefront_outlined),
    (AppointmentSource.phone, 'By phone', Icons.call_outlined),
  ];

  final AppointmentSource selected;
  final ValueChanged<AppointmentSource> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<AppointmentSource>(
        showSelectedIcon: false,
        segments: [
          for (final (value, label, icon) in _sources)
            ButtonSegment(value: value, label: Text(label), icon: Icon(icon)),
        ],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
