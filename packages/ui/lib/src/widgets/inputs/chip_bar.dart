import 'package:flutter/material.dart';

/// One choice out of a few, as a sideways-scrolling row of chips (stages, tabs of a list); each may carry a count.
class ChipBar<T> extends StatelessWidget {
  const ChipBar({super.key, required this.options, required this.selected, required this.onSelected});

  final List<({T value, String label, int? count})> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: options.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final option = options[i];
        return ChoiceChip(
          label: Text(option.count == null ? option.label : '${option.label} ${option.count}'),
          selected: option.value == selected,
          onSelected: (_) => onSelected(option.value),
        );
      },
    ),
  );
}
