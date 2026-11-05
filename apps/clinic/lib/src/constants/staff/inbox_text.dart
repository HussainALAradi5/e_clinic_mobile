/// Wording of the staff notifications.
abstract final class InboxText {
  static const notifications = 'Notifications';
  static const searchNotifications = 'Search notifications';
  static const read = 'Read';
  static const everything = 'Everything';
  static const emptyHint = 'Ticket updates, bookings and other news land here.';
  static String count(int n) => '$n ${n == 1 ? 'notification' : 'notifications'}';

  static const allRead = 'All notifications marked as read.';
  static const noNotificationsYet = 'No notifications yet';
  static const noMatch = 'Nothing matches these filters';
  static String emptyTitle({required bool filtered}) => filtered ? noMatch : noNotificationsYet;
}
