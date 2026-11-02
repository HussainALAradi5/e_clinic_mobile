part of 'message_bubble.dart';

class _Quote extends StatelessWidget {
  const _Quote({required this.quote, required this.meId, required this.onTap});

  final ChatReplyQuote quote;
  final String meId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const white = Colors.white;
    final what = switch (quote.kind) {
      'voice' => '🎤 Voice note',
      'media' => '📎 ${quote.excerpt.isNotEmpty ? quote.excerpt : quote.fileName ?? 'File'}',
      _ => quote.excerpt,
    };
    return Semantics(
      button: true,
      label: 'Show the message from ${quote.senderName}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: white, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote.senderId == meId ? 'You' : quote.senderName,
                style: text.labelMedium?.copyWith(color: white, fontWeight: FontWeight.w700),
              ),
              Text(
                what,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: white.withValues(alpha: 0.88)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
