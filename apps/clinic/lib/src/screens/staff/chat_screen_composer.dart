part of 'chat_screen.dart';

/// The box: a "Replying to …" card while replying, the chosen photo, the text, photo and send buttons.
class _Composer extends StatelessWidget {
  const _Composer({
    required this.text,
    required this.focus,
    required this.sending,
    required this.replyTo,
    required this.meId,
    required this.photo,
    required this.onCancelReply,
    required this.onPhoto,
    required this.onRemovePhoto,
    required this.onSend,
  });

  final TextEditingController text;
  final FocusNode focus;
  final bool sending;
  final ChatMessage? replyTo;
  final String meId;
  final XFile? photo;
  final VoidCallback onCancelReply;
  final VoidCallback onPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = !sending && (text.text.trim().isNotEmpty || photo != null);
    return Material(
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (replyTo case final r?)
                Container(
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
                      IconButton(
                        tooltip: 'Cancel reply',
                        onPressed: onCancelReply,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
              if (photo case final p?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InputChip(
                    avatar: const Icon(Icons.image_outlined),
                    label: Text(p.name, overflow: TextOverflow.ellipsis),
                    onDeleted: onRemovePhoto,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(tooltip: 'Add a photo', onPressed: onPhoto, icon: const Icon(Icons.photo_camera_outlined)),
                  Expanded(
                    child: TextField(
                      controller: text,
                      focusNode: focus,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 4000,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        counterText: '',
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: canSend ? onSend : null,
                    icon: sending
                        ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
