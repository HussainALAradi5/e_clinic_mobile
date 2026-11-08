/// Records that have an event log (GET /activity/{entity}/{id}).
enum ActivityEntity {
  patientProfile('patient_profile');

  const ActivityEntity(this.wire);

  /// The value the API takes.
  final String wire;
}
