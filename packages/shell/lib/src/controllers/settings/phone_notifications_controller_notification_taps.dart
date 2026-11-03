part of 'phone_notifications_controller.dart';

/// The last phone notification the person tapped (the app listens: marks it read and opens its record, else the
/// inbox). Null until a tap.
class NotificationTaps extends Notifier<TappedNotification?> {
  @override
  TappedNotification? build() => null;

  /// [payload] is what SystemNotifications put on the notification: `{id, related_type, related_id}` as JSON.
  void tapped(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      state = (
        id: json['id'] as String,
        relatedType: json['related_type'] as String?,
        relatedId: json['related_id'] as String?,
      );
    } on FormatException {
      // A notification from an older version: nothing to open.
    }
  }

  /// The pending tap, cleared so it is opened only once.
  TappedNotification? take() {
    final tap = state;
    state = null;
    return tap;
  }
}
