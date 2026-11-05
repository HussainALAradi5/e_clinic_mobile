import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/appointment_text.dart';
import '../../../controllers/staff/staff_providers.dart';
import '../appointments/appointment_card.dart';

/// The day's bookings in the chosen [stage]. A saved copy (offline) shows a banner and read-only cards.
class ScheduleVisits extends StatelessWidget {
  const ScheduleVisits({super.key, required this.day, required this.stage, required this.mine, required this.onRetry});

  final TodaySchedule day;
  final VisitStage stage;

  /// Only my bookings (the provider is not shown on the cards).
  final bool mine;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final visits = day.visits;
    final shown = visits.where(stage.includes).toList();
    final offline = day.cachedAt != null;
    return Column(
      children: [
        if (day.cachedAt case final savedAt?)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: OfflineBanner(savedAt: savedAt, onRetry: onRetry),
          ),
        if (shown.isEmpty)
          EmptyState(
            icon: Icons.event_available_outlined,
            title: visits.isEmpty ? AppointmentText.nothingBookedToday : AppointmentText.noBookingsHere,
            message: visits.isEmpty
                ? (mine ? AppointmentText.noneBookedWithYou : AppointmentText.noneBookedInClinic)
                : AppointmentText.pickAnotherStage,
          ),
        for (final visit in shown)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: AppointmentCard(visit: visit, showProvider: !mine, readOnly: offline),
          ),
      ],
    );
  }
}
