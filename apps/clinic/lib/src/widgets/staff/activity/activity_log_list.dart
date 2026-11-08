import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/activity_log_limits.dart';
import '../../../constants/staff/activity_log_text.dart';
import '../../../controllers/staff/activity_log_state.dart';
import 'activity_entry_row.dart';
import 'activity_load_more.dart';

/// The latest events in view, the rest behind a collapse that also loads further pages.
class ActivityLogList extends StatelessWidget {
  const ActivityLogList({super.key, required this.log, required this.onLoadMore});

  final ActivityLogState log;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    final preview = log.entries.take(ActivityLogLimits.preview);
    final rest = log.entries.skip(ActivityLogLimits.preview).toList();
    final loadMore = log.hasMore
        ? ActivityLoadMore(isLoading: log.isLoadingMore, hasFailed: log.hasLoadMoreFailed, onPressed: onLoadMore)
        : null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in preview) ActivityEntryRow(key: ValueKey(entry.id), entry: entry),
          if (rest.isNotEmpty)
            AppCollapse(
              title: Text(
                ActivityLogText.more(rest.length, hasMore: log.hasMore),
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in rest) ActivityEntryRow(key: ValueKey(entry.id), entry: entry),
                  ?loadMore,
                ],
              ),
            )
          else
            ?loadMore,
        ],
      ),
    );
  }
}
