import 'package:flutter/material.dart';

import '../../theme/status_colors.dart';
import '../status/status_badge.dart';

/// One labelled value; empty values are left out by [FactList].
typedef Fact = ({String label, String? value});

/// Label / value rows inside a card. A label listed in [tones] shows its value as a badge of that colour.
class FactList extends StatelessWidget {
  const FactList({super.key, required this.facts, this.tones = const {}});

  final List<Fact> facts;
  final Map<String, StatusTone> tones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shown = facts.where((f) => f.value != null && f.value!.trim().isNotEmpty).toList();
    return Column(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(
                    shown[i].label,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(child: _value(shown[i], theme)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _value(Fact fact, ThemeData theme) {
    final tone = tones[fact.label];
    if (tone == null) return Text(fact.value!, style: theme.textTheme.bodyMedium);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: StatusBadge(label: fact.value!, tone: tone),
    );
  }
}
