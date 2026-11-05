import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/clock_text.dart';
import '../../controllers/staff/earning_providers.dart';
import '../../controllers/staff/staff_providers.dart';
import '../../widgets/staff/clock/clock_card.dart';
import '../../widgets/staff/clock/earning_card.dart';

/// `/hr/attendance/clock` — clock in / out with the day's punches. Works only on the clinic network; elsewhere the
/// server says so and HR records the day by hand.
class ClockScreen extends ConsumerWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text(ClockText.clockInOut)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(todayClockProvider)
            ..invalidate(myEarningProvider);
          await ref.read(todayClockProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const ClockCard(large: true),
            const EarningCard(),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 0),
              child: Text(
                ClockText.rules,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            const SectionHeader(ClockText.leaveAndPayslips),
            Text(ClockText.hrOnWebsite, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
