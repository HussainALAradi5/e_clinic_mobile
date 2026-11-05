part of 'chat_screen.dart';

/// Under the messages: the composer, or a read-only note once the chat was deleted.
class _ChatFooter extends StatelessWidget {
  const _ChatFooter({
    required this.chat,
    required this.sending,
    required this.replyTo,
    required this.meId,
    required this.onCancelReply,
    required this.onSend,
  });

  final Conversation chat;
  final bool sending;
  final ChatMessage? replyTo;
  final String meId;
  final VoidCallback onCancelReply;
  final Future<bool> Function(String body, XFile? photo) onSend;

  @override
  Widget build(BuildContext context) {
    if (chat.deletedAt != null) {
      return InfoNote(icon: Icons.delete_sweep_outlined, text: ChatText.deletedBy(chat.deletedBy));
    }
    return _Composer(sending: sending, replyTo: replyTo, meId: meId, onCancelReply: onCancelReply, onSend: onSend);
  }
}
