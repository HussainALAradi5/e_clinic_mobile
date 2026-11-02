part of 'staff_providers.dart';

/// Where a booking is in the visit: one chip each on the Today page.
enum VisitStage {
  all('All', []),
  expected('Expected', [AppointmentStatus.pending, AppointmentStatus.confirmed]),
  waiting('Waiting', [AppointmentStatus.checkedIn]),
  withProvider('With doctor', [AppointmentStatus.inProgress]),
  done('Done', [AppointmentStatus.completed, AppointmentStatus.noShow]);

  const VisitStage(this.label, this.statuses);

  final String label;
  final List<AppointmentStatus> statuses;

  bool includes(Appointment visit) => this == all || statuses.contains(visit.status);
}
