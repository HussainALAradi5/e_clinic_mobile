import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// A message's kind as a coloured round icon (visits blue, results purple, urgent red …); faded once read.
class NotificationKindIcon extends StatelessWidget {
  const NotificationKindIcon({super.key, required this.kind, this.unread = true});

  final NotificationKind kind;
  final bool unread;

  static IconData iconOf(NotificationKind kind) => switch (kind) {
    NotificationKind.visit => Icons.event_rounded,
    NotificationKind.treatment => Icons.self_improvement_rounded,
    NotificationKind.result => Icons.biotech_rounded,
    NotificationKind.pharmacy => Icons.medication_rounded,
    NotificationKind.billing => Icons.payments_rounded,
    NotificationKind.hr => Icons.badge_rounded,
    NotificationKind.chat => Icons.forum_rounded,
    NotificationKind.support => Icons.support_agent_rounded,
    NotificationKind.urgent => Icons.priority_high_rounded,
    NotificationKind.files => Icons.download_done_rounded,
    NotificationKind.system => Icons.notifications_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tone = StatusColors.tone('NotificationKind', kind.name);
    final strong = StatusEdge.of(tone, brightness);
    final colors = StatusColors.of(tone, brightness);
    return CircleAvatar(
      radius: 20,
      backgroundColor: unread ? strong : colors.background,
      child: Icon(iconOf(kind), size: 20, color: unread ? Colors.white : colors.foreground),
    );
  }
}
