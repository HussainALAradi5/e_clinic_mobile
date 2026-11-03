part of 'chats_screen.dart';

/// Long-press a chat: Open, Mark as read (when unread) and Delete chat (when allowed).
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
            title: const Text('Open'),
            onTap: () => Navigator.pop(context, _ChatMenuChoice.open),
          ),
          if (chat.unreadCount > 0)
            ListTile(
              leading: const Icon(Icons.done_all_rounded),
              title: const Text('Mark as read'),
              onTap: () => Navigator.pop(context, _ChatMenuChoice.read),
            ),
          if (chat.canDelete)
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: error),
              title: Text('Delete chat', style: TextStyle(color: error)),
              onTap: () => Navigator.pop(context, _ChatMenuChoice.delete),
            ),
        ],
      ),
    );
  }
}
