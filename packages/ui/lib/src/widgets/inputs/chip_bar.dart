import 'package:flutter/material.dart';

import '../../theme/status_colors.dart';
import 'filter_pill.dart';

/// One choice out of a few, as a sideways-scrolling filter track (stages, tabs of a list); each may carry a count.
/// With [tone], enum values wear their badge colour; return null for a neutral choice such as "All".
class ChipBar<T> extends StatelessWidget {
  const ChipBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.tone,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final List<({T value, String label, int? count})> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final StatusTone? Function(T value)? tone;
  final EdgeInsetsGeometry padding;

  static const double _trackPadding = 3;
  static const double _gap = 2;
  static const double _radius = 999;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: padding,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_trackPadding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: _gap,
          children: [
            for (final option in options)
              FilterPill(
                label: option.count == null ? option.label : '${option.label} ${option.count}',
                selected: option.value == selected,
                onSelected: () => onSelected(option.value),
                tone: tone?.call(option.value),
              ),
          ],
        ),
      ),
    ),
  );
}
