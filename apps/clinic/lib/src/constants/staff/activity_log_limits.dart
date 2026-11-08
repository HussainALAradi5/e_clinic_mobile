/// How much of the event log is fetched and shown at once.
abstract final class ActivityLogLimits {
  static const pageSize = 20;

  /// Entries always in view; the rest sit in the collapse.
  static const preview = 3;
}
