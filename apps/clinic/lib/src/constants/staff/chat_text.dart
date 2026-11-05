import 'package:e_clinic_data/data.dart';

import '../common/common_text.dart';

/// Wording and sizes of the staff chat screens.
abstract final class ChatText {
  static const title = 'Chat';
  static const newChat = 'New chat';
  static const noChats = 'No chats here';
  static const noChatsHint = 'Try another filter, or start a new chat.';
  static const search = 'Name, phone, email or staff no.';
  static const nobody = 'No one in the clinic matches.';
  static const more = 'Show more';
  static String count(int shown, int total) => '$shown of $total';

  static const info = 'Chat info';
  static const groupInfo = 'Group info';
  static const moreOptions = 'More options';
  static const mute = 'Mute notifications';
  static const unmute = 'Unmute';
  static const muted = 'Muted';
  static const mutedDone = 'Chat muted — no badge or alerts from it; mentions still reach you.';
  static const unmutedDone = 'Chat unmuted.';
  static String deletedBy(String? name) => 'Deleted by ${name ?? 'someone'} — read-only.';
  static const members = 'Members';

  static const open = 'Open';
  static const markRead = 'Mark as read';
  static const leave = 'Exit group';
  static String leaveTitle(String title) => 'Exit "$title"?';
  static const leaveMessage =
      'You stop getting its messages and can no longer write in it. It stays in your chats, read-only, until you delete it.';
  static String left(String title) => 'You left "$title".';
  static const youLeft = 'You left this group. You can still read it, not write in it.';
  static const leftRow = 'You left this group';
  static const deleteChat = 'Delete chat';
  static String deleteTitle(String title) => 'Delete "$title" from your chats?';
  static const deleteDirectMessage =
      'It goes from your list only; the other person keeps it. If they write again, the chat comes back with the new messages.';
  static const deleteGroupMessage = 'It goes from your list only; the members keep it. Nothing is erased.';
  static const deleted = 'Chat deleted from your list.';

  static const online = 'Online';
  static const offline = 'Offline';
  static const goOffline = 'You show as online — tap to appear offline';
  static const goOnline = 'You show as offline — tap to appear online';
  static String memberCount(int count) => count == 1 ? '1 member' : '$count members';
  static const you = 'You';
  static const muteChoices = {
    MuteDuration.eightHours: '8 hours',
    MuteDuration.oneWeek: '1 week',
    MuteDuration.always: 'Until I unmute',
  };

  /// Colleagues fetched per page.
  static const pageSize = 20;

  /// Wait after typing before searching.
  static const debounce = Duration(milliseconds: 300);

  static const groups = 'Groups';
  static const oneToOne = 'One-to-one';
  static const youLeadThisGroup = 'You lead this group';
  static const searchChats = 'Search chats or people';
  static const message = 'Message';
  static const noMessagesYet = 'No messages yet';
  static const sayHello = 'Say hello.';
  static const cancelReply = 'Cancel reply';
  static const checkingFile = 'Checking file…';
  static const reply = 'Reply';
  static const copyText = 'Copy text';
  static const addPhoto = CommonText.addPhoto;
  static const send = CommonText.send;

  static String replyingTo(String? name) => 'Replying to ${name ?? 'yourself'}';
  static String showQuoted(String? name) => 'Show the message from $name';

  static const groupCreated = 'Group created';
  static const sayHelloRow = 'Say hello';
  static const youPrefix = 'You: ';
  static const file = 'File';
  static const copied = 'Copied.';
  static const quoteNotLoaded = 'That message is further back — scroll up to load it.';
  static const voiceNote = 'Voice note';
  static const fewerEmojis = 'Fewer emojis';
  static const moreEmojis = 'More emojis';
  static String removeReaction(String emoji) => 'Remove reaction $emoji';
  static String react(String emoji) => 'React $emoji';
}
