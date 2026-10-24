/// Which app is running; sent when registering a push device and used in the token's device name.
enum MobileApp {
  patient,
  staff;

  /// `flutter-patient` / `flutter-staff` — shown in the user's list of signed-in devices.
  String get deviceName => 'flutter-$name';
}

/// Per-app settings, provided by each app's `main.dart` through [appConfigProvider].
class AppConfig {
  const AppConfig({
    required this.app,
    required this.apiBaseUrl,
    required this.lockAfter,
  });

  final MobileApp app;

  /// Server origin plus `/api/v1`, e.g. `https://api.clinic.bh/api/v1` (passed with `--dart-define=API_URL=...`).
  final String apiBaseUrl;

  /// Time in the background after which the app asks to unlock again (patient 5 min, staff 2 min).
  final Duration lockAfter;
}
