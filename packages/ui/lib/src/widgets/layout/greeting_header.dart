import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Top of a home screen: today's date and a greeting by the time of day, with optional actions (messages bell).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.firstName, this.trailing});

  final String firstName;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = ClinicClock.now().hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 18 ? 'Good afternoon' : 'Good evening');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ClinicClock.day(ClinicClock.today()),
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(firstName.isEmpty ? greeting : '$greeting, $firstName', style: theme.textTheme.headlineSmall),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
