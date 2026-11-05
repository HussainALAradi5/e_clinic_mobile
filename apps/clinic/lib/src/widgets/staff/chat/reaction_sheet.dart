import 'package:flutter/material.dart';

import '../../../constants/staff/chat_text.dart';

part 'reaction_sheet_actions_sheet.dart';
part 'reaction_sheet_actions_sheet_state.dart';
part 'reaction_sheet_copy_action.dart';
part 'reaction_sheet_react_action.dart';
part 'reaction_sheet_reply_action.dart';

/// Emoji in colour: the default text font draws plain glyphs for some (❤️, ⚠️) on Android.
const emojiStyle = TextStyle(
  fontFamily: 'Noto Color Emoji',
  fontFamilyFallback: ['Apple Color Emoji', 'Segoe UI Emoji'],
);

/// What the long-press sheet of a message answered.
sealed class MessageAction {
  const MessageAction();
}

/// Long-press a message: the quick reactions (mine ringed — picking it again takes it back), "+" for the full set,
/// Reply and Copy. Dismiss by dragging down or tapping outside: nothing has to be picked.
Future<MessageAction?> showMessageActions(
  BuildContext context, {
  required List<String> quick,
  required List<String> all,
  required String? mine,
  required bool canCopy,
}) => showModalBottomSheet<MessageAction>(
  context: context,
  showDragHandle: true,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (context) => _ActionsSheet(quick: quick, all: all, mine: mine, canCopy: canCopy),
);
