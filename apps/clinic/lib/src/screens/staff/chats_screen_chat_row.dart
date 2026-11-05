part of 'chats_screen.dart';

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat, required this.meId, required this.onTap, required this.onLongPress});

  final Conversation chat;
  final String meId;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  String get _preview {
    if (chat.left) return ChatText.leftRow;
    final m = chat.lastMessage;
    if (m == null) return chat.isGroup ? 'Group created' : 'Say hello';
    final who = m.sender.id == meId ? 'You: ' : (chat.isGroup ? '${m.sender.fullName.split(' ').first}: ' : '');
    final what = switch (m.kind) {
      'voice' => '🎤 Voice note',
      'media' when (m.body ?? '').isEmpty => '📎 ${m.attachments.firstOrNull?.isImage ?? false ? 'Photo' : 'File'}',
      _ => m.body ?? '',
    };
    return '$who$what';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = chat.unreadCount > 0;
    final when = chat.activity;
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ChatAvatar(
        name: chat.title,
        seed: chat.partnerId ?? chat.id,
        url: chat.avatarUrl,
        group: chat.isGroup,
        online: chat.partnerOnline,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              chat.title,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: unread ? FontWeight.w700 : null),
            ),
          ),
          if (chat.isGroup && chat.iLead) ...[
            const SizedBox(width: 4),
            Icon(Icons.star_rounded, size: 16, color: Colors.amber.shade700, semanticLabel: 'You lead this group'),
          ],
        ],
      ),
      subtitle: Text(_preview, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (when != null)
            Text(
              ClinicClock.ago(when),
              style: theme.textTheme.labelSmall?.copyWith(color: unread ? const Color(0xFF15803D) : null),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (chat.muted)
                Icon(Icons.notifications_off_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
              if (unread) ...[
                const SizedBox(width: 4),
                // A muted chat keeps its count, in a quiet grey; a new count pops in.
                PopIn(
                  key: ValueKey(chat.unreadCount),
                  child: Badge(
                    label: Text(chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}'),
                    backgroundColor: chat.muted ? theme.colorScheme.outline : const Color(0xFF15803D),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
