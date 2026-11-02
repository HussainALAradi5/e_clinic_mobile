import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/staff/staff_providers.dart';
import '../../../utilities/staff/clock_location.dart';
import '../../../utilities/staff/formatters.dart';

part 'clock_card_clock_body.dart';

/// One-tap clock in / out with today's state. The server accepts it only from the clinic network and works out
/// late arrival and overtime from the shift.
class ClockCard extends ConsumerWidget {
  const ClockCard({super.key, this.large = false});

  /// The full clock page: bigger text, the day's punches listed.
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayClockProvider);
    return today.when(
      loading: () => SkeletonList(count: 1, height: large ? 220 : 120),
      error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(todayClockProvider)),
      data: (t) => _ClockBody(today: t, large: large),
    );
  }
}
