import 'package:flutter/material.dart';

/// Allergies in red at the top of a patient file, so nobody misses them.
class MedicalAlertCard extends StatelessWidget {
  const MedicalAlertCard({super.key, required this.allergies});

  final String allergies;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Allergies', style: text.titleSmall?.copyWith(color: scheme.onErrorContainer)),
                  const SizedBox(height: 2),
                  Text(allergies, style: text.bodyMedium?.copyWith(color: scheme.onErrorContainer)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
