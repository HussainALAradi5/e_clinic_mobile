part of 'message_bubble.dart';

/// What sits inside the bubble: sender name (first of a run in a group), the quote, photos, files, text and time.
class _BubbleContent extends StatelessWidget {
  const _BubbleContent({
    required this.message,
    required this.meId,
    required this.showSender,
    required this.leader,
    required this.onQuote,
    required this.onOpen,
  });

  final ChatMessage message;
  final String meId;
  final bool showSender;
  final bool leader;
  final ValueChanged<String> onQuote;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final m = message;
    final theme = Theme.of(context);
    const white = Colors.white;
    final time = ClinicClock.local(m.createdAt);
    final stamp = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showSender)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    m.sender.fullName,
                    style: theme.textTheme.labelMedium?.copyWith(color: white, fontWeight: FontWeight.w700),
                  ),
                ),
                if (leader) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.star_rounded, size: 14, color: white),
                  Text(' Leader', style: theme.textTheme.labelSmall?.copyWith(color: white)),
                ],
              ],
            ),
          ),
        if (m.replyTo case final q?) _Quote(quote: q, meId: meId, onTap: () => onQuote(q.id)),
        for (final img in m.attachments.where((f) => f.isImage))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: img.url == null
                  ? const _Pending()
                  : GestureDetector(
                      onTap: () => onOpen(img.url!),
                      child: Image.network(img.url!, fit: BoxFit.cover, height: 180, width: double.infinity),
                    ),
            ),
          ),
        for (final f in m.attachments.where((f) => !f.isImage))
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: ActionChip(
              avatar: Icon(m.kind == 'voice' ? Icons.mic_rounded : Icons.attach_file_rounded, size: 18),
              label: Text(m.kind == 'voice' ? 'Voice note' : f.name, overflow: TextOverflow.ellipsis),
              onPressed: f.url == null ? null : () => onOpen(f.url!),
            ),
          ),
        if (m.body case final body? when body.isNotEmpty)
          Text(body, style: theme.textTheme.bodyLarge?.copyWith(color: white)),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(stamp, style: theme.textTheme.labelSmall?.copyWith(color: white.withValues(alpha: 0.8))),
        ),
      ],
    );
  }
}
