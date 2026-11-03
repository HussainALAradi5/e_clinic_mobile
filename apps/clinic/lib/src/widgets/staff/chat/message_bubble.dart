import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_avatar.dart';
import 'reaction_sheet.dart' show emojiStyle;

part 'message_bubble_bubble_colors.dart';
part 'message_bubble_content.dart';
part 'message_bubble_pending.dart';
part 'message_bubble_quote.dart';
part 'message_bubble_reaction_pill.dart';
part 'message_bubble_swipe_to_reply.dart';

/// One message: mine on the right, others on the left with their avatar and name (first of a run). A quote card
/// when it is a reply (tap: show the original), photos, files, a voice note, time, and reaction pills under it.
/// **Swipe right** to reply (the bubble follows the finger, an arrow shows, a light tick at the threshold);
/// **long-press** for reactions, Reply and Copy.
class MessageBubble extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final m = message;
    final theme = Theme.of(context);
    final mine = m.sender.id == meId;
    final leader = group && m.sender.role == 'admin';
    final color = leader
        ? BubbleColors.leader
        : mine
        ? BubbleColors.mine
        : BubbleColors.others;

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.76),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(!mine && first ? 4 : 16),
          topRight: Radius.circular(mine && first ? 4 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        boxShadow: highlight
            ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.6), blurRadius: 0, spreadRadius: 3)]
            : null,
      ),
      child: _BubbleContent(
        message: m,
        meId: meId,
        showSender: group && !mine && first,
        leader: leader,
        onQuote: onQuote,
        onOpen: _open,
      ),
    );

    final mineReaction = m.reactionOf(meId);
    return Padding(
      padding: EdgeInsets.only(top: first ? 10 : 3, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine && group)
            SizedBox(
              width: 36,
              child: first
                  ? ChatAvatar(name: m.sender.fullName, seed: m.sender.id, url: m.sender.avatarUrl, size: 30)
                  : null,
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _SwipeToReply(onMenu: onMenu, onReply: onReply, child: bubble),
                if (m.reactions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final r in m.reactions)
                          _ReactionPill(reaction: r, mine: r.emoji == mineReaction, onTap: () => onReact(r.emoji)),
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
