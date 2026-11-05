part of 'chat_screen.dart';

/// The open chat under its bar: the messages, then the composer (or the read-only note).
class _ChatBody extends StatelessWidget {
  const _ChatBody({
    required this.chat,
    required this.thread,
    required this.scroll,
    required this.meId,
    required this.reactions,
    required this.replyTo,
    required this.pick,
    required this.onReply,
    required this.onReact,
    required this.onCancelReply,
    required this.onSend,
    required this.onDelete,
  });

  final Conversation chat;
  final ChatThreadController thread;
  final ScrollController scroll;
  final String meId;
  final ({List<String> quick, List<String> all})? reactions;
  final ChatMessage? replyTo;
  final int pick;
  final ValueChanged<ChatMessage> onReply;
  final Future<void> Function(ChatMessage message, String emoji) onReact;
  final VoidCallback onCancelReply;
  final Future<bool> Function(String body, XFile? photo) onSend;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Expanded(
        child: _MessageList(
          chat: chat,
          messages: thread.messages,
          hasMore: thread.hasMore,
          scroll: scroll,
          meId: meId,
          reactions: reactions,
          onReply: onReply,
          pickedId: replyTo?.id,
          pick: pick,
          onReact: onReact,
        ),
      ),
      _ChatFooter(
        chat: chat,
        sending: thread.sending,
        replyTo: replyTo,
        meId: meId,
        onCancelReply: onCancelReply,
        onSend: onSend,
        onDelete: onDelete,
      ),
    ],
  );
}
