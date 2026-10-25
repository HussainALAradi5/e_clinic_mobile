/// Who the app is serving, as the server's device registry knows it (`notifications/devices`). One app serves both:
/// the signed-in account decides which.
enum MobileApp {
  patient,
  staff;

  static MobileApp forAccount({required bool isPatient}) => isPatient ? patient : staff;
}

/// App settings, provided by `main.dart` through [appConfigProvider].
class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    this.patientLockAfter = const Duration(minutes: 5),
    this.staffLockAfter = const Duration(minutes: 2),
  });

  /// Shown in the user's list of signed-in devices.
  static const deviceName = 'flutter-e-clinic';

  /// Server origin plus `/api/v1`, e.g. `https://api.clinic.bh/api/v1` (passed with `--dart-define=API_URL=...`).
  final String apiBaseUrl;

  /// Time in the background after which the app asks to unlock again. Staff phones hold many patients' data, so
  /// they lock sooner.
  final Duration patientLockAfter;
  final Duration staffLockAfter;

  Duration lockAfterFor({required bool isPatient}) => isPatient ? patientLockAfter : staffLockAfter;
}
