import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/activity_log_limits.dart';
import 'activity_log_state.dart';

/// The record whose event log is shown.
typedef ActivityTarget = ({ActivityEntity entity, String id});

/// One record's event log: the first page, then the next one on request.
class ActivityLogController extends AsyncNotifier<ActivityLogState> {
  ActivityLogController(this.target);

  final ActivityTarget target;

  Future<Paged<ActivityEntry>> _fetch(ActivityRepository repo, {String? cursor}) =>
      repo.list(target.entity, target.id, perPage: ActivityLogLimits.pageSize, cursor: cursor);

  @override
  Future<ActivityLogState> build() async {
    final page = await _fetch(ref.watch(activityRepositoryProvider));
    return ActivityLogState(entries: page.items, nextCursor: page.meta.nextCursor);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(ActivityLogState(entries: current.entries, nextCursor: current.nextCursor, isLoadingMore: true));
    try {
      final page = await _fetch(ref.read(activityRepositoryProvider), cursor: current.nextCursor);
      if (!ref.mounted) return;
      state = AsyncData(
        ActivityLogState(entries: [...current.entries, ...page.items], nextCursor: page.meta.nextCursor),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        ActivityLogState(entries: current.entries, nextCursor: current.nextCursor, hasLoadMoreFailed: true),
      );
    }
  }
}

final activityLogProvider = AsyncNotifierProvider.autoDispose
    .family<ActivityLogController, ActivityLogState, ActivityTarget>(ActivityLogController.new);
