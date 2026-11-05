part of 'chat_screen.dart';

/// The chat's bar: who it is with, the info button and the three-dot menu (info, mute, exit, delete).
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.chat,
    required this.onInfo,
    required this.onMute,
    required this.onLeave,
    required this.onDelete,
  });

  final Conversation chat;
  final VoidCallback onInfo;
  final Future<void> Function(MuteDuration? duration) onMute;
  final VoidCallback onLeave;
  final VoidCallback onDelete;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    titleSpacing: 0,
    title: _ChatTitle(chat: chat),
    actions: [
      TapScale(
        child: IconButton(
          tooltip: chat.isGroup ? ChatText.groupInfo : ChatText.info,
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: onInfo,
        ),
      ),
      ChatMenu(chat: chat, onInfo: onInfo, onMute: onMute, onLeave: onLeave, onDelete: onDelete),
    ],
  );
}
