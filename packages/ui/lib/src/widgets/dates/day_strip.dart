import 'package:flutter/material.dart';

import 'day_chip.dart';

/// A row of [DayChip]s that scrolls sideways (booking a day, a therapist's week).
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.days, required this.selected, required this.onSelected});

  final List<String> days;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 84,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: days.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => DayChip(date: days[i], selected: days[i] == selected, onTap: () => onSelected(days[i])),
    ),
  );
}
