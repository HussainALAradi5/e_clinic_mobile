import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/system_notifications.dart';
import '../auth/session_controller.dart';

part 'phone_notifications_controller_notification_taps.dart';

final notificationTapsProvider = NotifierProvider<NotificationTaps, int>(NotificationTaps.new);

/// The phone's notification tray, shared by the switch and the inbox watcher.
final systemNotificationsProvider = Provider<SystemNotifications>(
  (ref) => SystemNotifications(onTap: () => ref.read(notificationTapsProvider.notifier).tapped()),
);

/// The person's switch for phone and browser notifications (the server's `push` opt-out); null while signed out.
class PhoneNotificationsController extends AsyncNotifier<bool?> {
  @override
  Future<bool?> build() async {
    if (ref.watch(currentUserProvider) == null) return null;
    return ref.read(notificationRepositoryProvider).pushEnabled();
  }

  /// Turning on asks the phone for permission first; the switch stays off when the phone says no.
  /// Returns false when the phone refused.
  Future<bool> set(bool on) async {
    if (on && !await ref.read(systemNotificationsProvider).requestPermission()) return false;
    final enabled = await ref.read(notificationRepositoryProvider).setPushEnabled(on);
    state = AsyncData(enabled);
    return true;
  }
}

final phoneNotificationsProvider = AsyncNotifierProvider<PhoneNotificationsController, bool?>(
  PhoneNotificationsController.new,
);
