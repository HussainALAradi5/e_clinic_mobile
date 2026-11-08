/// Wording of the event log.
abstract final class ActivityLogText {
  static const title = 'Event log';
  static const empty = 'No events yet.';
  static const system = 'System';
  static const loadMore = 'Load more';
  static const loadMoreFailed = 'Could not load more — try again';

  /// How many more are loaded; [hasMore] means further pages are still on the server.
  static String more(int count, {required bool hasMore}) {
    final noun = count == 1 && !hasMore ? 'event' : 'events';
    return '$count${hasMore ? '+' : ''} more $noun';
  }

  static String changed(String label, String from, String to) => '$label from $from to $to';
  static String set(String label, String to) => '$label set to $to';
  static String cleared(String label, String from) => '$label cleared (was $from)';
  static String touched(String label) => '$label changed';
}
