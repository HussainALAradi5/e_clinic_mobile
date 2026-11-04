part of 'chat_screen.dart';

/// The box: a "Replying to …" card while replying, the chosen photo, the text, photo and send buttons. It owns
/// the text and the photo, and clears them once [onSend] reports the message was sent.
class _Composer extends StatefulWidget {
  const _Composer({
    required this.sending,
    required this.replyTo,
    required this.meId,
    required this.onCancelReply,
    required this.onSend,
  });

  final bool sending;
  final ChatMessage? replyTo;
  final String meId;
  final VoidCallback onCancelReply;

  /// Sends the text and photo; true when it was sent.
  final Future<bool> Function(String body, XFile? photo) onSend;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final _text = TextEditingController();
  final _focus = FocusNode();
  XFile? _photo;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(_Composer old) {
    super.didUpdateWidget(old);
    if (widget.replyTo != null && widget.replyTo != old.replyTo) _focus.requestFocus();
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!await widget.onSend(_text.text.trim(), _photo) || !mounted) return;
    _text.clear();
    setState(() => _photo = null);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = !widget.sending && (_text.text.trim().isNotEmpty || _photo != null);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: Motion.of(context, Motion.base),
                switchInCurve: Motion.pop,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                ),
                child: switch (widget.replyTo) {
                  final r? => _ReplyPreview(
                    key: ValueKey(r.id),
                    replyTo: r,
                    meId: widget.meId,
                    onCancel: widget.onCancelReply,
                  ),
                  null => const SizedBox.shrink(),
                },
              ),
              if (_photo case final p?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InputChip(
                    avatar: const Icon(Icons.image_outlined),
                    label: Text(p.name, overflow: TextOverflow.ellipsis),
                    onDeleted: () => setState(() => _photo = null),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Add a photo',
                    onPressed: () async {
                      final picked = await pickPhoto(context);
                      if (picked != null && mounted) setState(() => _photo = picked);
                    },
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      focusNode: _focus,
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
                    onPressed: canSend ? _send : null,
                    icon: widget.sending
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
