import 'package:freezed_annotation/freezed_annotation.dart';

import '../../enums/identity/notification_kind.dart';
import '../../utilities/identity/notification_kind_of.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// Mirror of NotificationResource — one message of the in-app inbox.
@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String template,
    String? subject,
    required String body,
    String? relatedType,
    String? relatedId,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  const AppNotification._();

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  bool get unread => readAt == null;

  /// What it is about (visit, result, chat …): its colour, icon and sound.
  NotificationKind get kind => notificationKindOf(template);
}
