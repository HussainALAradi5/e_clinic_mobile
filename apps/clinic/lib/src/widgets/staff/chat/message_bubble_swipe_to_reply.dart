part of 'message_bubble.dart';

/// Wraps a bubble: **swipe right** to reply (the bubble follows the finger, an arrow shows, a light tick at the
/// threshold), **long-press** for the message menu.
class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({required this.onMenu, required this.onReply, required this.child});

  final VoidCallback onMenu;
  final VoidCallback onReply;
  final Widget child;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply> {
  static const _replyAt = 64.0;
  var _drag = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onMenu();
      },
      onHorizontalDragUpdate: (d) => setState(() {
        final next = (_drag + d.delta.dx).clamp(0.0, _replyAt + 16);
        if (_drag < _replyAt && next >= _replyAt) HapticFeedback.selectionClick();
        _drag = next;
      }),
      onHorizontalDragEnd: (_) {
        if (_drag >= _replyAt) widget.onReply();
        setState(() => _drag = 0);
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          if (_drag > 0)
            Positioned(
              left: -4,
              child: Opacity(
                opacity: (_drag / _replyAt).clamp(0.2, 1),
                child: Icon(Icons.reply_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          AnimatedContainer(
            duration: Duration(milliseconds: _drag == 0 ? 160 : 0),
            transform: Matrix4.translationValues(_drag, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
