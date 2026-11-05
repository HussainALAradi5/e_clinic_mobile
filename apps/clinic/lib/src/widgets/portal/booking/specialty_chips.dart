import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';

/// A scrolling row of specialties, "All" first; picking one filters the doctors.
class SpecialtyChips extends StatelessWidget {
  const SpecialtyChips({super.key, required this.specialties, required this.selectedId, required this.onSelected});

  final List<Specialty> specialties;
  final String? selectedId;
  final ValueChanged<Specialty?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final s in [null, ...specialties])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(s?.name ?? CommonText.all),
                selected: selectedId == s?.id,
                onSelected: (_) => onSelected(s),
              ),
            ),
        ],
      ),
    );
  }
}
