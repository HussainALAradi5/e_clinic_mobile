part of 'chat_screen.dart';

/// Under the messages: the composer, or a read-only note once the chat was deleted or I exited the group.
class _ChatFooter extends StatelessWidget {
  const _ChatFooter({
    required this.chat,
    required this.sending,
    required this.replyTo,
    required this.meId,
    required this.onCancelReply,
    required this.onSend,
    required this.onDelete,
  });

  final Conversation chat;
  final bool sending;
  final ChatMessage? replyTo;
  final String meId;
  final VoidCallback onCancelReply;
  final Future<bool> Function(String body, XFile? photo) onSend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (chat.deletedAt != null) {
      return InfoNote(icon: Icons.delete_sweep_outlined, text: ChatText.deletedBy(chat.deletedBy));
    }
    if (chat.left) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              const Expanded(child: InfoNote(icon: Icons.logout_rounded, text: ChatText.youLeft)),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text(ChatText.deleteChat),
              ),
            ],
          ),
        ),
      );
    }
    return _Composer(sending: sending, replyTo: replyTo, meId: meId, onCancelReply: onCancelReply, onSend: onSend);
  }
}
