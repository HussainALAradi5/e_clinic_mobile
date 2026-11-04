part of 'chat_screen.dart';

/// "Replying to …" above the box: who and what is being answered, with a button to cancel the reply.
class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({super.key, required this.replyTo, required this.meId, required this.onCancel});

  final ChatMessage replyTo;
  final String meId;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = replyTo;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: scheme.primary, width: 3)),
      ),
      child: Row(
        children: [
          Icon(Icons.reply_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${r.sender.id == meId ? 'yourself' : r.sender.fullName}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  r.body?.isNotEmpty == true ? r.body! : (r.attachments.firstOrNull?.name ?? 'File'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(tooltip: 'Cancel reply', onPressed: onCancel, icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}
