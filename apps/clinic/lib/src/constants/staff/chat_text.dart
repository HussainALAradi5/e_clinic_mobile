/// Wording and sizes of the staff chat screens.
abstract final class ChatText {
  static const newChat = 'New chat';
  static const search = 'Name, phone, email or staff no.';
  static const nobody = 'No one in the clinic matches.';
  static const more = 'Show more';
  static String count(int shown, int total) => '$shown of $total';

  /// Colleagues fetched per page.
  static const pageSize = 20;

  /// Wait after typing before searching.
  static const debounce = Duration(milliseconds: 300);
}
