import 'package:e_clinic_data/data.dart';

/// Wording and sizes of the staff chat screens.
abstract final class ChatText {
  static const newChat = 'New chat';
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
}
