import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Avatar with initials, name and up to two lines under it (account and profile pages).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.name, this.lines = const []});

  final String name;

  /// Shown muted under the name; empty lines are left out.
  final List<String?> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Text(initials(name), style: theme.textTheme.titleLarge),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: theme.textTheme.titleLarge),
              for (final line in lines)
                if (line != null && line.isNotEmpty)
                  Text(line, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
