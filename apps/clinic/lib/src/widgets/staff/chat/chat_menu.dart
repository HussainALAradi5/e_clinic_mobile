import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/chat_text.dart';

/// The ⋮ of an open chat (one-to-one or group): chat info, and mute for 8 hours / 1 week / until unmuted — or
/// unmute. Muting is mine only; mentions still reach me.
class ChatMenu extends StatelessWidget {
  const ChatMenu({super.key, required this.chat, required this.onInfo, required this.onMute});

  final Conversation chat;
  final VoidCallback onInfo;
  final ValueChanged<MuteDuration?> onMute;

  @override
  Widget build(BuildContext context) => PopupMenuButton<Object>(
    tooltip: ChatText.moreOptions,
    icon: const Icon(Icons.more_vert_rounded),
    onSelected: (choice) => switch (choice) {
      'info' => onInfo(),
      'unmute' => onMute(null),
      final MuteDuration d => onMute(d),
      _ => null,
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'info',
        child: ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: Text(chat.isGroup ? ChatText.groupInfo : ChatText.info),
        ),
      ),
      if (chat.muted)
        const PopupMenuItem(
          value: 'unmute',
          child: ListTile(leading: Icon(Icons.notifications_active_outlined), title: Text(ChatText.unmute)),
        )
      else ...[
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: ListTile(leading: Icon(Icons.notifications_off_outlined), title: Text(ChatText.mute)),
        ),
        for (final MapEntry(key: duration, value: label) in ChatText.muteChoices.entries)
          PopupMenuItem(
            value: duration,
            child: Padding(padding: const EdgeInsets.only(left: 56), child: Text(label)),
          ),
      ],
    ],
  );
}
