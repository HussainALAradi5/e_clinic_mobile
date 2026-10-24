import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Doctors who take online bookings and the specialties they cover.
typedef BookingChoices = ({List<Specialty> specialties, List<Doctor> doctors});

final bookingChoicesProvider = FutureProvider.autoDispose<BookingChoices>((ref) async {
  final doctorsRepo = ref.watch(doctorRepositoryProvider);
  final (specialties, doctors) = await (
    doctorsRepo.specialties(const ListQuery(perPage: 100, sort: ['name'])),
    doctorsRepo.list(
      const ListQuery(perPage: 100, filter: AllOf([Where.eq('isAcceptingPatients', true)])),
    ),
  ).wait;
  final bookable = doctors.items.where((d) => d.isBookable != false).toList();
  final offered = {for (final d in bookable) d.specialtyId};
  return (
    specialties: specialties.items.where((s) => offered.contains(s.id)).toList(),
    doctors: bookable,
  );
});

/// Free times of a doctor on a day for a kind of visit.
typedef SlotKey = ({String doctorId, String date, AppointmentType type});

final slotsProvider = FutureProvider.autoDispose.family<List<Slot>, SlotKey>(
  (ref, key) => ref
      .watch(portalRepositoryProvider)
      .slots(doctorId: key.doctorId, date: key.date, type: key.type),
);
