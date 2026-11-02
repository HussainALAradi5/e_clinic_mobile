part of 'staff_providers.dart';

/// Only my own bookings. Starts on for people who treat patients; front desk staff start with the whole clinic.
/// (Accounts that can only read their own bookings get just those from the server either way.)
class OnlyMine extends Notifier<bool> {
  @override
  bool build() => ref.watch(accessProvider).can('appointments.treat');

  void set(bool value) => state = value;
}
