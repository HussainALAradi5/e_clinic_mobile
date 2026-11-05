import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../constants/common/notification_link_text.dart';
import 'notification_kind_icon.dart';

/// One notification in full: its kind, subject, message and time, with Close and — when it is about a page the
/// app has — a ghost button to that place ("Open result", "Open appointment"). [show] is true when the person
/// chose to go there.
class NotificationMessageSheet extends StatelessWidget {
  const NotificationMessageSheet({super.key, required this.item, required this.hasLink});

  final AppNotification item;
  final bool hasLink;

  static Future<bool> show(BuildContext context, AppNotification item, {required bool hasLink}) async =>
      await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (_) => NotificationMessageSheet(item: item, hasLink: hasLink),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NotificationKindIcon(kind: item.kind),
                const SizedBox(width: 12),
                Expanded(child: Text(item.subject ?? NotificationLinkText.message, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 14),
            Text(item.body, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              ClinicClock.dateTime(item.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text(NotificationLinkText.close)),
                if (hasLink)
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(NotificationLinkText.openFor(item.relatedType)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
