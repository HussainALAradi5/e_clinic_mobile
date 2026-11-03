part of 'chat_screen.dart';

/// The messages, newest at the bottom, with a day separator where the day changes and a spinner while older
/// pages remain. Long-press opens a message's menu (reactions, Reply, Copy); a tapped quote scrolls to its
/// original and flashes it.
class _MessageList extends StatefulWidget {
  const _MessageList({
    required this.chat,
    required this.messages,
    required this.hasMore,
    required this.scroll,
    required this.meId,
    required this.reactions,
    required this.onReply,
    required this.onReact,
  });

  final Conversation chat;
  final List<ChatMessage> messages;
  final bool hasMore;
  final ScrollController scroll;
  final String meId;
  final ({List<String> quick, List<String> all})? reactions;
  final ValueChanged<ChatMessage> onReply;
  final Future<void> Function(ChatMessage message, String emoji) onReact;

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final _keys = <String, GlobalKey>{};
  String? _flash;

  Future<void> _menu(ChatMessage message) async {
    final action = await showMessageActions(
      context,
      quick: widget.reactions?.quick ?? fallbackReactions,
      all: widget.reactions?.all ?? fallbackReactions,
      mine: message.reactionOf(widget.meId),
      canCopy: (message.body ?? '').isNotEmpty,
    );
    if (!mounted) return;
    switch (action) {
      case ReactAction(:final emoji):
        await widget.onReact(message, emoji);
      case ReplyAction():
        widget.onReply(message);
      case CopyAction():
        await Clipboard.setData(ClipboardData(text: message.body ?? ''));
        if (mounted) AppSnack.success(context, 'Copied.');
      case null:
        break;
    }
  }

  /// A quote was tapped: scroll its original into view and flash it (when loaded).
  Future<void> _jump(String id) async {
    final target = _keys[id]?.currentContext;
    if (target == null) {
      AppSnack.info(context, 'That message is further back — scroll up to load it.');
      return;
    }
    await Scrollable.ensureVisible(target, alignment: 0.4, duration: const Duration(milliseconds: 300));
    setState(() => _flash = id);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() => _flash = null);
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    if (messages.isEmpty) {
      return const EmptyState(icon: Icons.waving_hand_outlined, title: 'No messages yet', message: 'Say hello.');
    }
    return ListView.builder(
      controller: widget.scroll,
      reverse: true,
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      itemCount: messages.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == messages.length) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final m = messages[i];
        final older = i + 1 < messages.length ? messages[i + 1] : null;
        final day = ClinicClock.isoDate(ClinicClock.local(m.createdAt));
        final newDay = older == null || ClinicClock.isoDate(ClinicClock.local(older.createdAt)) != day;
        return Column(
          key: _keys.putIfAbsent(m.id, GlobalKey.new),
          children: [
            if (newDay) _DaySeparator(label: ClinicClock.relativeDay(day)),
            MessageBubble(
              message: m,
              meId: widget.meId,
              group: widget.chat.isGroup,
              first: newDay || older.sender.id != m.sender.id,
              highlight: _flash == m.id,
              onMenu: () => _menu(m),
              onReply: () => widget.onReply(m),
              onReact: (e) => widget.onReact(m, e),
              onQuote: _jump,
            ),
          ],
        );
      },
    );
  }
}
