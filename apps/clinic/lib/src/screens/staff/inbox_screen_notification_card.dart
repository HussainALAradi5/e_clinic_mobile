part of 'inbox_screen.dart';

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  static const _blue = Color(0xFF2563EB);

  static IconData _icon(String? type) => switch (type) {
    'support_ticket' => Icons.support_agent_rounded,
    'appointment' => Icons.event_rounded,
    'clinical_order' => Icons.biotech_rounded,
    'conversation' => Icons.forum_rounded,
    'leave_request' => Icons.beach_access_rounded,
    'payslip' => Icons.payments_rounded,
    _ => Icons.notifications_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final link = StaffPaths.forNotification(item.relatedType, item.relatedId);
    // Unread: light blue card and a blue icon; read: the default card.
    final background = item.unread
        ? Color.alphaBlend(_blue.withValues(alpha: dark ? 0.22 : 0.10), scheme.surfaceContainerLowest)
        : null;
    return Card(
      margin: EdgeInsets.zero,
      color: background,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: item.unread ? _blue : scheme.surfaceContainerHighest,
                child: Icon(
                  _icon(item.relatedType),
                  size: 20,
                  color: item.unread ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject ?? item.body,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: item.unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (item.subject != null) ...[
                      const SizedBox(height: 2),
                      Text(item.body, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(ClinicClock.ago(item.createdAt), style: theme.textTheme.bodySmall),
                        const Spacer(),
                        if (link != null)
                          Text('Open ›', style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
