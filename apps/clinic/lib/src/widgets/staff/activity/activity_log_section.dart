import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/activity_log_text.dart';
import '../../../controllers/staff/activity_log_controller.dart';
import 'activity_log_list.dart';

/// The read-only event log of a record, newest first. Show it only with `activity.read_all`.
class ActivityLogSection extends ConsumerWidget {
  const ActivityLogSection({super.key, required this.entity, required this.id});

  final ActivityEntity entity;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = activityLogProvider((entity: entity, id: id));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(ActivityLogText.title),
        ref
            .watch(provider)
            .when(
              loading: () => const SkeletonList(count: 3, height: 56),
              error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(provider)),
              data: (log) => log.entries.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: InfoNote(icon: Icons.history_rounded, text: ActivityLogText.empty),
                    )
                  : ActivityLogList(log: log, onLoadMore: () => ref.read(provider.notifier).loadMore()),
            ),
      ],
    );
  }
}
