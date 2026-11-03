part of 'phone_notifications_controller.dart';

/// Taps on a phone notification (the app listens and opens its inbox).
class NotificationTaps extends Notifier<int> {
  @override
  int build() => 0;

  void tapped() => state++;
}
