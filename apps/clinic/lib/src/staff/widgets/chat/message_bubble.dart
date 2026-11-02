import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_avatar.dart';

/// Colours of the bubbles (the web's defaults): mine blue, others green, a group leader's amber.
abstract final class BubbleColors {
  static const mine = Color(0xFF1D4ED8);
  static const others = Color(0xFF15803D);
  static const leader = Color(0xFFB45309);
}

/// One message: mine on the right, others on the left with their avatar and name (first of a run). A quote card
/// when it is a reply (tap: show the original), photos, files, a voice note, time, and reaction pills under it.
/// **Swipe right** to reply (the bubble follows the finger, an arrow shows, a light tick at the threshold);
/// **long-press** for reactions, Reply and Copy.
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.meId,
    required this.group,
    required this.first,
    required this.onMenu,
    required this.onReply,
    required this.onReact,
    required this.onQuote,
    this.highlight = false,
  });

  final ChatMessage message;
  final String meId;
  final bool group;

  /// First of a run from the same sender (shows avatar and name).
  final bool first;
  final VoidCallback onMenu;
  final VoidCallback onReply;

  /// Tap a reaction pill: toggles that emoji.
  final ValueChanged<String> onReact;

  /// Tap the quote: show the quoted message.
  final ValueChanged<String> onQuote;

  /// Flash once (opened from a quote).
  final bool highlight;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  static const _replyAt = 64.0;
  var _drag = 0.0;

  @override
  Widget build(BuildContext context) {
    final m = widget.message;
    final theme = Theme.of(context);
    final mine = m.sender.id == widget.meId;
    final leader = widget.group && m.sender.role == 'admin';
    final color = leader
        ? BubbleColors.leader
        : mine
        ? BubbleColors.mine
        : BubbleColors.others;
    final images = [
      for (final f in m.attachments)
        if (f.isImage) f,
    ];
    final files = [
      for (final f in m.attachments)
        if (!f.isImage) f,
    ];
    final time = ClinicClock.local(m.createdAt);
    final stamp = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    const white = Colors.white;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(!mine && widget.first ? 4 : 16),
          topRight: Radius.circular(mine && widget.first ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        boxShadow: widget.highlight
            ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.6), blurRadius: 0, spreadRadius: 3)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.group && !mine && widget.first)
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
          if (m.replyTo case final q?) _Quote(quote: q, meId: widget.meId, onTap: () => widget.onQuote(q.id)),
          for (final img in images)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: img.url == null
                    ? const _Pending()
                    : GestureDetector(
                        onTap: () => _open(img.url!),
                        child: Image.network(img.url!, fit: BoxFit.cover, height: 180, width: double.infinity),
                      ),
              ),
            ),
          for (final f in files)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ActionChip(
                avatar: Icon(m.kind == 'voice' ? Icons.mic_rounded : Icons.attach_file_rounded, size: 18),
                label: Text(m.kind == 'voice' ? 'Voice note' : f.name, overflow: TextOverflow.ellipsis),
                onPressed: f.url == null ? null : () => _open(f.url!),
              ),
            ),
          if (m.body case final body? when body.isNotEmpty)
            Text(body, style: theme.textTheme.bodyLarge?.copyWith(color: white)),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(stamp, style: theme.textTheme.labelSmall?.copyWith(color: white.withValues(alpha: 0.8))),
          ),
        ],
      ),
    );

    final mineReaction = m.reactionOf(widget.meId);
    return Padding(
      padding: EdgeInsets.only(top: widget.first ? 10 : 3, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine && widget.group)
            SizedBox(
              width: 36,
              child: widget.first
                  ? ChatAvatar(name: m.sender.fullName, seed: m.sender.id, url: m.sender.avatarUrl, size: 30)
                  : null,
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
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
                            child: Icon(Icons.reply_rounded, color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: _drag == 0 ? 160 : 0),
                        transform: Matrix4.translationValues(_drag, 0, 0),
                        child: bubble,
                      ),
                    ],
                  ),
                ),
                if (m.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final r in m.reactions)
                          _ReactionPill(
                            reaction: r,
                            mine: r.emoji == mineReaction,
                            onTap: () => widget.onReact(r.emoji),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

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
          child: Text('${reaction.emoji} ${reaction.count}', style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending();

  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    color: Colors.black26,
    alignment: Alignment.center,
    child: const Text('Checking file…', style: TextStyle(color: Colors.white)),
  );
}
