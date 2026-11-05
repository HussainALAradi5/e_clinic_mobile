part of 'chats_screen.dart';

/// My chats, paged as I scroll; pull to refresh. Tap opens a chat, long-press opens its menu.
class _ChatList extends StatelessWidget {
  const _ChatList({
    required this.reloadKey,
    required this.load,
    required this.meId,
    required this.onRefresh,
    required this.onOpen,
    required this.onMenu,
  });

  final Object reloadKey;
  final Future<Paged<Conversation>> Function(int page) load;
  final String meId;
  final VoidCallback onRefresh;
  final ValueChanged<Conversation> onOpen;
  final ValueChanged<Conversation> onMenu;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: () async => onRefresh(),
    child: InfiniteList<Conversation>(
      reloadKey: reloadKey,
      load: load,
      empty: const EmptyState(icon: Icons.forum_outlined, title: ChatText.noChats, message: ChatText.noChatsHint),
      itemBuilder: (context, chat, _) =>
          _ChatRow(chat: chat, meId: meId, onTap: () => onOpen(chat), onLongPress: () => onMenu(chat)),
    ),
  );
}
