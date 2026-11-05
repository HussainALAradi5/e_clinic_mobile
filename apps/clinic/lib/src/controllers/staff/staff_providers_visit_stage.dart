part of 'staff_providers.dart';

/// Where a booking is in the visit: one chip each on the Today page.
enum VisitStage {
  all(VisitActionText.stageAll, []),
  expected(VisitActionText.stageExpected, [AppointmentStatus.pending, AppointmentStatus.confirmed]),
  waiting(VisitActionText.stageWaiting, [AppointmentStatus.checkedIn]),
  withProvider(VisitActionText.stageWithDoctor, [AppointmentStatus.inProgress]),
  done(VisitActionText.stageDone, [AppointmentStatus.completed, AppointmentStatus.noShow]);

  const VisitStage(this.label, this.statuses);

  final String label;
  final List<AppointmentStatus> statuses;

  bool includes(Appointment visit) => this == all || statuses.contains(visit.status);
}
