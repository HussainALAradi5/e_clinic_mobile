import 'package:e_clinic_core/core.dart';

import '../../models/identity/app_notification.dart';

part 'notification_repository_inbox_read.dart';

/// The signed-in user's in-app inbox and push devices.
class NotificationRepository {
  const NotificationRepository(this._api);

  final ApiClient _api;

  /// Unread first; filters, search and paging on the server. [read] narrows to `unread` or `read` ones;
  /// `meta.unreadCount` carries the badge number.
  Future<Paged<AppNotification>> inbox(ListQuery query, {InboxRead read = InboxRead.all}) => _api.list(
    'notifications/mine',
    query,
    AppNotification.fromJson,
    extra: {if (read != InboxRead.all) 'read': read.name},
  );

  Future<int> unreadCount() async =>
      (await inbox(const ListQuery(perPage: 1), read: InboxRead.unread)).meta.unreadCount ?? 0;

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
