import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/staff_providers.dart';
import '../widgets/clock/clock_card.dart';

/// `/hr/attendance/clock` — clock in / out with the day's punches. Works only on the clinic network; elsewhere the
/// server says so and HR records the day by hand.
class ClockScreen extends ConsumerWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Clock in / out')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayClockProvider);
          await ref.read(todayClockProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const ClockCard(large: true),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
              child: Text(
                'Check in works only on the clinic Wi-Fi. Arriving more than 10 minutes late is marked late; '
                'staying 15 minutes or more past your shift goes to your manager as overtime. '
                'Forgot to check in? Ask HR to correct the day.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            const SectionHeader('Leave and payslips'),
            Text(
              'Leave requests and payslips are under HR → My HR on the clinic website.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
