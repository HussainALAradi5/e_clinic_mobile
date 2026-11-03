import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chat steps with their confirmations and messages.
abstract final class ChatActions {
  /// Asks first, then deletes the chat (a soft delete: it disappears for everyone in it and an admin can restore
  /// it). True when it was deleted; errors are shown.
  static Future<bool> delete(BuildContext context, WidgetRef ref, Conversation chat) async {
    final ok = await showConfirmSheet(
      context,
      ConfirmConfig(
        title: 'Delete "${chat.title}"?',
        message: chat.isGroup
            ? 'The group disappears for every member. Nothing is erased — an admin can restore it.'
            : 'The chat disappears for both of you. Nothing is erased — an admin can restore it.',
        confirmLabel: 'Delete chat',
        danger: true,
      ),
    );
    if (!ok || !context.mounted) return false;
    try {
      await ref.read(chatRepositoryProvider).delete(chat.id);
      if (context.mounted) AppSnack.success(context, 'Chat deleted.');
      return true;
    } catch (e) {
      if (context.mounted) AppSnack.error(context, e);
      return false;
    }
  }
}
