import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/activity_log_text.dart';
import '../../../utilities/staff/activity_changes.dart';

/// One event as one sentence that wraps as text does; only the action is a badge.
class ActivityEntryRow extends StatelessWidget {
  const ActivityEntryRow({super.key, required this.entry});

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final changes = describeActivityChanges(entry.changes);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${entry.changedBy ?? ActivityLogText.system} '),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              // The span already scales its widget with the text; scaling the badge's own text too would double it.
              child: MediaQuery.withNoTextScaling(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: StatusChip(enumName: 'AuditAction', value: entry.action, label: entry.actionLabel),
                ),
              ),
            ),
            if (changes.isNotEmpty) TextSpan(text: ' $changes'),
            TextSpan(
              text: ' · ${ClinicClock.dateTime(entry.createdAt)}',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
