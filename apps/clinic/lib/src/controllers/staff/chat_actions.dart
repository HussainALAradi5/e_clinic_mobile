import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/chat_text.dart';

/// Chat steps with their confirmations and messages, shared by the chat list and the open chat.
abstract final class ChatActions {
  /// Asks first, then deletes the chat from my list only (soft: nothing is erased, the others keep it). A group
  /// must be exited first. True when it was deleted; errors are shown.
  static Future<bool> delete(BuildContext context, WidgetRef ref, Conversation chat) async {
    final ok = await showConfirmSheet(
      context,
      ConfirmConfig(
        title: ChatText.deleteTitle(chat.title),
        message: chat.isGroup ? ChatText.deleteGroupMessage : ChatText.deleteDirectMessage,
        confirmLabel: ChatText.deleteChat,
        danger: true,
      ),
    );
    if (!ok || !context.mounted) return false;
    return _run(context, () => ref.read(chatRepositoryProvider).delete(chat.id), done: ChatText.deleted);
  }

  /// Asks first, then exits the group (it stays on my list, read-only). True when done.
  static Future<bool> leave(BuildContext context, WidgetRef ref, Conversation chat) async {
    final me = ref.read(currentUserProvider)?.id;
    if (me == null) return false;
    final ok = await showConfirmSheet(
      context,
      ConfirmConfig(
        title: ChatText.leaveTitle(chat.title),
        message: ChatText.leaveMessage,
        confirmLabel: ChatText.leave,
        danger: true,
      ),
    );
    if (!ok || !context.mounted) return false;
    return _run(context, () => ref.read(chatRepositoryProvider).leave(chat.id, me), done: ChatText.left(chat.title));
  }

  /// Mutes for [duration], or unmutes (null). True when done.
  static Future<bool> mute(BuildContext context, WidgetRef ref, Conversation chat, MuteDuration? duration) => _run(
    context,
    () => ref.read(chatRepositoryProvider).mute(chat.id, duration),
    done: duration == null ? ChatText.unmutedDone : ChatText.mutedDone,
  );

  /// Lets me pick how long to mute; null when the sheet is closed.
  static Future<MuteDuration?> pickMute(BuildContext context) => showModalBottomSheet<MuteDuration>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text(ChatText.mute)),
          for (final MapEntry(key: duration, value: label) in ChatText.muteChoices.entries)
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined),
              title: Text(label),
              onTap: () => Navigator.pop(context, duration),
            ),
        ],
      ),
    ),
  );

  static Future<bool> _run(BuildContext context, Future<Object?> Function() call, {required String done}) async {
    try {
      await call();
      if (context.mounted) AppSnack.success(context, done);
      return true;
    } catch (e) {
      if (context.mounted) AppSnack.error(context, e);
      return false;
    }
  }
}
