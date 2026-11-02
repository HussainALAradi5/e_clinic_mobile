part of 'staff_providers.dart';

/// The day shown on the Sessions page (`YYYY-MM-DD`).
class SessionsDay extends Notifier<String> {
  @override
  String build() => ClinicClock.today();

  void set(String day) => state = day;
}
