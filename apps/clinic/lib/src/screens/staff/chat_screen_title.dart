part of 'chat_screen.dart';

/// The app bar title: the chat's avatar and name, and for a group the member count and first names.
class _ChatTitle extends StatelessWidget {
  const _ChatTitle({required this.chat});

  final Conversation chat;

  @override
  Widget build(BuildContext context) {
    final others = chat.members.where((m) => !m.isMe).map((m) => m.fullName.split(' ').first);
    return Row(
      children: [
        ChatAvatar(
          name: chat.title,
          seed: chat.partnerId ?? chat.id,
          url: chat.avatarUrl,
          group: chat.isGroup,
          size: 38,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(child: Text(chat.title, overflow: TextOverflow.ellipsis)),
                  if (chat.muted) ...[
                    const SizedBox(width: 6),
                    PopIn(
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 16,
                        semanticLabel: ChatText.muted,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (chat.isGroup)
                Text(
                  '${chat.members.length} members · ${others.join(', ')}',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
