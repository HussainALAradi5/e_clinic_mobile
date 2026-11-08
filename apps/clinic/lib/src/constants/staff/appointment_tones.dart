import 'package:e_clinic_ui/ui.dart';

/// Badge colours of the people and file on an appointment. Same as the web (`APPOINTMENT_PERSON_TONES`).
abstract final class AppointmentTones {
  static const patient = StatusTone.teal;
  static const doctor = StatusTone.indigo;
  static const file = StatusTone.cyan;
}
