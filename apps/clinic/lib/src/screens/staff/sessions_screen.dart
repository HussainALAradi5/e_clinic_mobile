import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/session_text.dart';
import '../../controllers/staff/staff_providers.dart';
import '../../widgets/staff/appointments/appointment_card.dart';

/// `/clinic/sessions` — the therapist's treatment sessions for a day (today and the week ahead): start a session
/// when the patient is in, complete it when done. Attendance and plan progress follow from these steps.
class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  static const _daysAhead = 7;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(sessionsDayProvider);
    final today = ClinicClock.today();
    final days = [for (var i = 0; i < _daysAhead; i++) ClinicClock.addDays(today, i)];
    return Scaffold(
      appBar: AppBar(title: const Text(SessionText.mySessions)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sessionsProvider);
          await ref.read(sessionsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 4),
            DayStrip(days: days, selected: day, onSelected: ref.read(sessionsDayProvider.notifier).set),
            SectionHeader(ClinicClock.relativeDay(day)),
            ref
                .watch(sessionsProvider)
                .when(
                  loading: () => const SkeletonList(count: 3, height: 140),
                  error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(sessionsProvider)),
                  data: (sessions) => sessions.isEmpty
                      ? const EmptyState(
                          icon: Icons.self_improvement_outlined,
                          title: SessionText.noSessions,
                          message: SessionText.noSessionsHint,
                        )
                      : Column(
                          children: [
                            for (final session in sessions)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: AppointmentCard(visit: session, showProvider: false),
                              ),
                          ],
                        ),
                ),
          ],
        ),
      ),
    );
  }
}
