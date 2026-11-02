part of 'ticket_detail_screen.dart';

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});

  final TicketComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = comment.isMe;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine
              ? Color.alphaBlend(const Color(0xFF2563EB).withValues(alpha: 0.14), scheme.surfaceContainerLowest)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mine ? 'You' : comment.author.fullName, style: theme.textTheme.labelMedium),
                if (comment.author.isSupport) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(99)),
                    child: Text(
                      'SUPPORT',
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer, fontSize: 9),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Text(ClinicClock.ago(comment.createdAt), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
