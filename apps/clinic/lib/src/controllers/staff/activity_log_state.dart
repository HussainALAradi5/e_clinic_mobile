import 'package:e_clinic_data/data.dart';

/// The event log entries loaded so far and where the next page starts.
class ActivityLogState {
  const ActivityLogState({
    required this.entries,
    this.nextCursor,
    this.isLoadingMore = false,
    this.hasLoadMoreFailed = false,
  });

  final List<ActivityEntry> entries;
  final String? nextCursor;
  final bool isLoadingMore;
  final bool hasLoadMoreFailed;

  bool get hasMore => nextCursor != null;
}
