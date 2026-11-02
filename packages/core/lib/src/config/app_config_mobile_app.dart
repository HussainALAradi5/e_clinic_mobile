part of 'app_config.dart';

/// Who the app is serving, as the server's device registry knows it (`notifications/devices`). One app serves both:
/// the signed-in account decides which.
enum MobileApp {
  patient,
  staff;

  static MobileApp forAccount({required bool isPatient}) => isPatient ? patient : staff;
}
