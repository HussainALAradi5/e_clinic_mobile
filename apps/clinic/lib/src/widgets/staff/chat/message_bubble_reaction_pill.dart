part of 'message_bubble.dart';

class _ReactionPill extends StatelessWidget {
  const _ReactionPill({required this.reaction, required this.mine, required this.onTap});

  final ChatReaction reaction;
  final bool mine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: '${reaction.emoji} ${reaction.count}: ${reaction.names.join(', ')}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFF60A5FA).withValues(alpha: 0.2) : scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: mine ? const Color(0xFF60A5FA) : scheme.outlineVariant),
          ),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: reaction.emoji, style: emojiStyle),
                TextSpan(text: ' ${reaction.count}'),
              ],
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
