/// Records that have an event log (GET /activity/{entity}/{id}). Each page has its own audience.
enum ActivityEntity {
  patientProfile('patient_profile', 'activity.read_all'),
  appointment('appointment', 'appointments.read_all'),
  clinicalOrder('clinical_order', 'orders.read_all'),
  supportTicket('support_ticket', 'tickets.read_all');

  const ActivityEntity(this.wire, this.readRight);

  /// The value the API takes.
  final String wire;

  /// Who may read the log on this page; the server checks the same right.
  final String readRight;
}
