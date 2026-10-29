import 'package:flutter/material.dart';

/// One labelled value; empty values are left out by [FactList].
typedef Fact = ({String label, String? value});

/// Label / value rows inside a card.
class FactList extends StatelessWidget {
  const FactList({super.key, required this.facts});

  final List<Fact> facts;

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
                Expanded(child: Text(shown[i].value!, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
