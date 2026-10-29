import 'package:freezed_annotation/freezed_annotation.dart';

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
}
