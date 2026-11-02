import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'staff_providers.dart';

/// The day shown on the calendar (`YYYY-MM-DD`).
class CalendarDay extends Notifier<String> {
  @override
  String build() => ClinicClock.today();

  void set(String day) => state = day;
}

final calendarDayProvider = NotifierProvider<CalendarDay, String>(CalendarDay.new);

/// One provider's column of the day: who, and their bookings in time order.
typedef ProviderDay = ({String providerId, String name, List<Appointment> bookings});

/// Groups a day's bookings by provider, providers by name (the phone shows the columns one under another).
List<ProviderDay> groupByProvider(List<Appointment> bookings) {
  final groups = <String, List<Appointment>>{};
  for (final booking in bookings) {
    if (offSchedule.contains(booking.status)) continue;
    groups.putIfAbsent(booking.providerId, () => []).add(booking);
  }
  final days = [
    for (final MapEntry(key: id, value: list) in groups.entries)
      (
        providerId: id,
        name: list.first.provider?.fullName ?? 'Provider',
        bookings: list..sort((a, b) => a.startTime.compareTo(b.startTime)),
      ),
  ];
  return days..sort((a, b) => a.name.compareTo(b.name));
}

/// Every booking of the chosen day, by provider; only mine follows the Today page's switch.
final calendarProvider = FutureProvider.autoDispose<List<ProviderDay>>((ref) async {
  ref.watch(scheduleVersionProvider);
  final day = ref.watch(calendarDayProvider);
  final me = ref.watch(onlyMineProvider) ? ref.watch(currentUserProvider)?.id : null;
  final bookings = await ref.watch(appointmentRepositoryProvider).calendar(from: day, to: day, providerId: me);
  return groupByProvider(bookings);
});

/// Who can be booked for a kind of visit.
final bookingProvidersProvider = FutureProvider.autoDispose.family<List<BookingProvider>, AppointmentType>(
  (ref, type) => ref.watch(appointmentRepositoryProvider).providers(type),
);

typedef StaffSlotKey = ({String providerId, String date, AppointmentType type});

/// Free times of a provider on a day.
final staffSlotsProvider = FutureProvider.autoDispose.family<List<Slot>, StaffSlotKey>(
  (ref, key) => ref
      .watch(appointmentRepositoryProvider)
      .availableSlots(providerId: key.providerId, date: key.date, type: key.type),
);
