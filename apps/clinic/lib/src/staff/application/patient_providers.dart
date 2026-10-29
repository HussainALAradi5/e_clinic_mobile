import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'staff_providers.dart';

/// What is typed in the patient search (name, file number or mobile).
class PatientSearch extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value.trim();
}

final patientSearchProvider = NotifierProvider.autoDispose<PatientSearch, String>(PatientSearch.new);

/// A page of patient files for the list (newest first, or the search matches).
ListQuery patientsQuery(String search, int page) =>
    ListQuery(page: page, perPage: 25, search: search.isEmpty ? null : search);

final patientProvider = FutureProvider.autoDispose.family<Patient, String>(
  (ref, id) => ref.watch(patientRepositoryProvider).get(id),
);

final patientTimelineProvider = FutureProvider.autoDispose.family<List<PatientTimelineEntry>, String>(
  (ref, id) => ref.watch(patientRepositoryProvider).timeline(id),
);

/// The patient's coming bookings (today on), soonest first.
final patientUpcomingProvider = FutureProvider.autoDispose.family<List<Appointment>, String>((ref, id) async {
  ref.watch(scheduleVersionProvider);
  final page = await ref
      .watch(appointmentRepositoryProvider)
      .list(
        ListQuery(
          perPage: 10,
          sort: const ['scheduledDate', 'startTime'],
          filter: AllOf([
            Where.eq('patientId', id),
            Where.gte('scheduledDate', ClinicClock.today()),
            const Where.noneOf('status', [...offSchedule, AppointmentStatus.completed, AppointmentStatus.noShow]),
          ]),
        ),
      );
  return page.items;
});
