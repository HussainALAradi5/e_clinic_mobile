import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'portal_providers_profile.dart';

/// Bumped after a booking or cancellation, so every visit list and the home page reload.
class VisitsVersion extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final visitsVersionProvider = NotifierProvider<VisitsVersion, int>(VisitsVersion.new);

/// Upcoming visits, soonest first.
FilterNode upcomingVisits() =>
    AllOf([const Where.oneOf('status', AppointmentStatus.upcoming), Where.gte('scheduledDate', ClinicClock.today())]);

/// The next three visits (home page).
final nextVisitsProvider = FutureProvider.autoDispose<List<Appointment>>((ref) async {
  ref.watch(visitsVersionProvider);
  final page = await ref
      .watch(appointmentRepositoryProvider)
      .list(ListQuery(perPage: 3, sort: const ['scheduledDate', 'startTime'], filter: upcomingVisits()));
  return page.items;
});

/// What is waiting in each area of the portal (home page).
typedef Glances = ({Treatment? treatment, int toCollect, ClinicalOrder? latestResult, Money due});

final glancesProvider = FutureProvider.autoDispose<Glances>((ref) async {
  ref.watch(visitsVersionProvider);
  const open = Where.oneOf('status', GenericStatus.open);
  final (treatments, prescriptions, results, invoices) = await (
    ref.watch(treatmentRepositoryProvider).list(const ListQuery(perPage: 1, filter: AllOf([open]))),
    ref.watch(prescriptionRepositoryProvider).list(const ListQuery(perPage: 20, filter: AllOf([open]))),
    ref
        .watch(clinicalOrderRepositoryProvider)
        .list(
          const ListQuery(
            perPage: 1,
            sort: ['-completedAt'],
            filter: AllOf([Where.eq('status', GenericStatus.completed)]),
          ),
        ),
    ref
        .watch(invoiceRepositoryProvider)
        .list(const ListQuery(perPage: 50, filter: AllOf([Where.oneOf('status', InvoiceStatus.owing)]))),
  ).wait;
  return (
    treatment: treatments.items.firstOrNull,
    toCollect: prescriptions.items.where((p) => p.collectable).length,
    latestResult: results.items.firstOrNull,
    due: Money.sum(invoices.items.map((i) => i.balanceDue)),
  );
});

final unreadCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);

final profileProvider = AsyncNotifierProvider.autoDispose<Profile, Patient>(Profile.new);

final treatmentsProvider = FutureProvider.autoDispose<List<Treatment>>(
  (ref) async =>
      (await ref.watch(treatmentRepositoryProvider).list(const ListQuery(perPage: 50, sort: ['status', '-createdAt'])))
          .items,
);

final treatmentSessionsProvider = FutureProvider.autoDispose.family<List<TreatmentSession>, String>(
  (ref, id) => ref.watch(treatmentRepositoryProvider).sessions(id),
);

final resultsProvider = FutureProvider.autoDispose<List<ClinicalOrder>>(
  (ref) async =>
      (await ref
              .watch(clinicalOrderRepositoryProvider)
              .list(
                const ListQuery(
                  perPage: 50,
                  sort: ['-completedAt'],
                  filter: AllOf([Where.eq('status', GenericStatus.completed)]),
                ),
              ))
          .items,
);

final resultDetailProvider = FutureProvider.autoDispose.family<ClinicalOrder, String>(
  (ref, id) => ref.watch(clinicalOrderRepositoryProvider).get(id),
);

final prescriptionsProvider = FutureProvider.autoDispose<List<Prescription>>(
  (ref) async =>
      (await ref.watch(prescriptionRepositoryProvider).list(const ListQuery(perPage: 50, sort: ['-createdAt']))).items,
);

final invoicesProvider = FutureProvider.autoDispose<List<Invoice>>(
  (ref) async =>
      (await ref.watch(invoiceRepositoryProvider).list(const ListQuery(perPage: 50, sort: ['-issueDate']))).items,
);

final invoiceDetailProvider = FutureProvider.autoDispose.family<Invoice, String>(
  (ref, id) => ref.watch(invoiceRepositoryProvider).get(id),
);

/// My sick leave certificates, newest first.
final sickLeavesProvider = FutureProvider.autoDispose<List<SickLeave>>(
  (ref) async =>
      (await ref.watch(sickLeaveRepositoryProvider).list(const ListQuery(perPage: 100, sort: ['-issuedAt']))).items,
);
