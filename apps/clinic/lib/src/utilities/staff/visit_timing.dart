import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';

import '../../constants/staff/appointment_text.dart';
import 'formatters.dart';

/// A patient counts as late this many minutes after the start (as on the web front-desk board).
const lateAfterMinutes = 10;

/// How the visit is running against the clock today: late (more than [lateAfterMinutes] past the start and not
/// checked in) or waiting since check-in. Null when there is nothing to say.
({String text, bool late})? visitTiming(Appointment visit, {DateTime? now}) {
  if (visit.scheduledDate != ClinicClock.today()) return null;
  final clock = now ?? ClinicClock.now();
  final minutesNow = clock.hour * 60 + clock.minute;
  if (visit.status == AppointmentStatus.pending || visit.status == AppointmentStatus.confirmed) {
    final [h, m] = visit.startTime.split(':').map(int.parse).toList();
    final late = minutesNow - (h * 60 + m);
    return late > lateAfterMinutes ? (text: AppointmentText.lateBy(formatMinutes(late)), late: true) : null;
  }
  final checkedIn = visit.checkedInAt;
  if (visit.status == AppointmentStatus.checkedIn && checkedIn != null) {
    final local = ClinicClock.local(checkedIn);
    final waiting = minutesNow - (local.hour * 60 + local.minute);
    return waiting >= 1 ? (text: AppointmentText.waitingFor(formatMinutes(waiting)), late: false) : null;
  }
  return null;
}
