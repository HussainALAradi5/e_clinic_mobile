import 'package:flutter/material.dart';

import '../../theme/status_colors.dart';

/// A choice chip in an enum value's badge colour (the same table as [StatusChip]): a coloured dot when off, the badge
/// fill and border when on. Without a [tone] it is a plain [ChoiceChip].
class ToneChip extends StatelessWidget {
  const ToneChip({super.key, required this.label, required this.selected, required this.onSelected, this.tone});

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final StatusTone? tone;

  @override
  Widget build(BuildContext context) {
    final tone = this.tone;
    if (tone == null) {
      return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
    }
    final colors = StatusColors.of(tone, Theme.of(context).brightness);
    return ChoiceChip(
      avatar: selected
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: colors.foreground, shape: BoxShape.circle),
            ),
      label: Text(label),
      labelStyle: TextStyle(color: selected ? colors.foreground : null, fontWeight: selected ? FontWeight.w600 : null),
      selected: selected,
      selectedColor: colors.background,
      checkmarkColor: colors.foreground,
      side: selected ? BorderSide(color: colors.border ?? colors.foreground) : null,
      onSelected: (_) => onSelected(),
    );
  }
}
