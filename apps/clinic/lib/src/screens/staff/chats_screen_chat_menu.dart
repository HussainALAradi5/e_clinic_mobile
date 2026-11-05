part of 'chats_screen.dart';

/// Long-press a chat: Open, Mark as read (when unread), Mute / Unmute, Exit group (still a member) and Delete chat
/// (a one-to-one chat any time, a group once exited).
class _ChatMenu extends StatelessWidget {
  const _ChatMenu({required this.chat});

  final Conversation chat;

  static Future<_ChatMenuChoice?> show(BuildContext context, Conversation chat) {
    unawaited(HapticFeedback.mediumImpact());
    return showModalBottomSheet<_ChatMenuChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ChatMenu(chat: chat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: Text(chat.title, style: Theme.of(context).textTheme.titleMedium)),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text(ChatText.open),
            onTap: () => Navigator.pop(context, _ChatMenuChoice.open),
          ),
          if (chat.unreadCount > 0)
            ListTile(
              leading: const Icon(Icons.done_all_rounded),
              title: const Text(ChatText.markRead),
              onTap: () => Navigator.pop(context, _ChatMenuChoice.read),
            ),
          if (chat.canMute)
            ListTile(
              leading: Icon(chat.muted ? Icons.notifications_active_outlined : Icons.notifications_off_outlined),
              title: Text(chat.muted ? ChatText.unmute : ChatText.mute),
              onTap: () => Navigator.pop(context, chat.muted ? _ChatMenuChoice.unmute : _ChatMenuChoice.mute),
            ),
          if (chat.canLeave)
            ListTile(
              leading: Icon(Icons.logout_rounded, color: error),
              title: Text(ChatText.leave, style: TextStyle(color: error)),
              onTap: () => Navigator.pop(context, _ChatMenuChoice.leave),
            ),
          if (chat.canDelete)
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: error),
              title: Text(ChatText.deleteChat, style: TextStyle(color: error)),
              onTap: () => Navigator.pop(context, _ChatMenuChoice.delete),
            ),
        ],
      ),
    );
  }
}
