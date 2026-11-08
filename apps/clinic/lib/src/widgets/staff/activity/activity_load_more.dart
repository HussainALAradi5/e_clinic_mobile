import 'package:flutter/material.dart';

import '../../../constants/staff/activity_log_text.dart';

/// Asks for the next page of the event log.
class ActivityLoadMore extends StatelessWidget {
  const ActivityLoadMore({super.key, required this.isLoading, required this.hasFailed, required this.onPressed});

  final bool isLoading;
  final bool hasFailed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }
    return TextButton(
      onPressed: onPressed,
      child: Text(hasFailed ? ActivityLogText.loadMoreFailed : ActivityLogText.loadMore, textAlign: TextAlign.center),
    );
  }
}
