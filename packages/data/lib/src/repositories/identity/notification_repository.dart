import 'package:e_clinic_core/core.dart';

import '../../models/identity/app_notification.dart';

/// The signed-in user's in-app inbox and push devices.
class NotificationRepository {
  const NotificationRepository(this._api);

  final ApiClient _api;

  /// `meta.unreadCount` carries the badge number.
  Future<Paged<AppNotification>> inbox(ListQuery query, {bool unreadOnly = false}) =>
      _api.list('notifications/mine', query, AppNotification.fromJson, extra: {if (unreadOnly) 'unread': 1});

  Future<int> unreadCount() async => (await inbox(const ListQuery(perPage: 1), unreadOnly: true)).meta.unreadCount ?? 0;

  Future<AppNotification> markRead(String id) =>
      _api.patch('notifications/$id/read', objectOf(AppNotification.fromJson));

  Future<void> markAllRead() => _api.patch('notifications/mine/read-all', ApiClient.ignore);

  Future<void> registerDevice({
    required String token,
    required MobileApp app,
    required String platform,
    String? deviceName,
  }) => _api.post(
    'notifications/devices',
    ApiClient.ignore,
    body: {'token': token, 'app': app.name, 'platform': platform, 'device_name': deviceName},
  );

  Future<void> unregisterDevice(String token) => _api.delete('notifications/devices/${Uri.encodeComponent(token)}');
}
