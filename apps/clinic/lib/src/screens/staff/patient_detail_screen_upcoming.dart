part of 'patient_detail_screen.dart';

/// The patient's booked visits, nearest first.
class _UpcomingVisits extends ConsumerWidget {
  const _UpcomingVisits({required this.patientId});

  final String patientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(patientUpcomingProvider(patientId))
      .when(
        loading: () => const SkeletonList(count: 1, height: 120),
        error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(patientUpcomingProvider(patientId))),
        data: (visits) => visits.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: InfoNote(icon: Icons.event_busy_rounded, text: PatientDetailText.noVisits),
              )
            : Column(
                children: [
                  for (final visit in visits)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: AppointmentCard(visit: visit, showDate: true),
                    ),
                ],
              ),
      );
}
