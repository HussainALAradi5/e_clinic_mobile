part of 'inbox_screen.dart';

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item, required this.onTap});

  final AppNotification item;
  final VoidCallback onTap;

  static const _blue = Color(0xFF2563EB);

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
              NotificationKindIcon(kind: item.kind, unread: item.unread),
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
                          Text(InboxText.openLink, style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary)),
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
