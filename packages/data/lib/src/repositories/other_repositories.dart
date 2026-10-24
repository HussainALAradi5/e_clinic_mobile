import 'package:e_clinic_core/core.dart';

import '../models/app_notification.dart';
import '../models/enum_catalog.dart';
import '../models/invoice.dart';
import '../models/prescription.dart';

class PrescriptionRepository {
  const PrescriptionRepository(this._api);

  final ApiClient _api;

  Future<Paged<Prescription>> list(ListQuery query) =>
      _api.list('pharmacy/prescriptions', query, Prescription.fromJson);
}

class InvoiceRepository {
  const InvoiceRepository(this._api);

  final ApiClient _api;

  Future<Paged<Invoice>> list(ListQuery query) => _api.list('billing/invoices', query, Invoice.fromJson);

  Future<Invoice> get(String id) => _api.get('billing/invoices/$id', objectOf(Invoice.fromJson));
}

/// The signed-in user's in-app inbox and push devices.
class NotificationRepository {
  const NotificationRepository(this._api);

  final ApiClient _api;

  /// `meta.unreadCount` carries the badge number.
  Future<Paged<AppNotification>> inbox(ListQuery query, {bool unreadOnly = false}) => _api.list(
    'notifications/mine',
    query,
    AppNotification.fromJson,
    extra: {if (unreadOnly) 'unread': 1},
  );

  Future<int> unreadCount() async =>
      (await inbox(const ListQuery(perPage: 1), unreadOnly: true)).meta.unreadCount ?? 0;

  Future<AppNotification> markRead(String id) =>
      _api.patch('notifications/$id/read', objectOf(AppNotification.fromJson));

  Future<void> markAllRead() => _api.patch('notifications/mine/read-all', ApiClient.ignore);

  Future<void> registerDevice({
    required String token,
    required MobileApp app,
    required String platform,
    String? deviceName,
  }) =>
      _api.post('notifications/devices', ApiClient.ignore, body: {
        'token': token,
        'app': app.name,
        'platform': platform,
        'device_name': deviceName,
      });

  Future<void> unregisterDevice(String token) =>
      _api.delete('notifications/devices/${Uri.encodeComponent(token)}');
}

/// Labels of every enum (loaded once per session).
class MetaRepository {
  const MetaRepository(this._api);

  final ApiClient _api;

  Future<EnumCatalog> enums() => _api.get('meta/enums', EnumCatalog.fromJson);
}
