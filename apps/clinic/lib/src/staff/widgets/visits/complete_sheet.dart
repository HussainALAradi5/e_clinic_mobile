import 'package:flutter/material.dart';

class CompleteSheet extends StatefulWidget {
  const CompleteSheet({super.key, required this.who});

  final String who;

  @override
  State<CompleteSheet> createState() => _CompleteSheetState();
}

class _CompleteSheetState extends State<CompleteSheet> {
  static const _choices = [(0, 'None'), (7, '1 week'), (14, '2 weeks'), (30, '1 month')];
  var _days = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Complete this visit?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${widget.who}. It is charged to the patient\'s invoice.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('Suggest a follow-up', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final (days, label) in _choices)
                  ChoiceChip(
                    label: Text(label),
                    selected: _days == days,
                    onSelected: (_) => setState(() => _days = days),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.of(context).pop(_days), child: const Text('Complete')),
            const SizedBox(height: 8),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Not now')),
          ],
        ),
      ),
    );
  }
}
