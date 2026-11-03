import 'dart:convert';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The phone's own notifications (the tray and the lock screen): asks for permission and shows a message. Each
/// [NotificationKind] has its own Android channel with its own sound and colour, so a result does not sound like
/// a chat, and people can mute one kind in the phone's settings. [onTap] gets the tapped message (its payload),
/// also when the tap started the app.
class SystemNotifications {
  SystemNotifications({required this.onTap});

  final void Function(String? payload) onTap;
  final _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  /// Channel ids carry a version: Android keeps a channel's first sound, so new sounds need new channels.
  static const _channelVersion = 'v2';

  Future<void> _init() async {
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) => onTap(response.payload),
    );
    _ready = true;
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    for (final kind in NotificationKind.values) {
      await android?.deleteNotificationChannel(channelId: 'clinic_${kind.name}');
    }
    // A tap that started the app: hand it over like any other tap.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) onTap(launch?.notificationResponse?.payload);
  }

  /// Sets up the plugin (and replays a tap that started the app); safe to call more than once.
  Future<void> init() => _init();

  /// Asks the phone (Android 13+, iOS) for permission once; true when allowed.
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      if (await android.areNotificationsEnabled() ?? false) return true;
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  Future<void> show({
    required int id,
    required NotificationKind kind,
    required String title,
    required String body,
    required AppNotification message,
  }) async {
    await _init();
    final tone = StatusColors.tone('NotificationKind', kind.name);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'clinic_${kind.name}_$_channelVersion',
          kind.label,
          channelDescription: 'e-Clinic messages: ${kind.label.toLowerCase()}.',
          importance: kind == NotificationKind.urgent ? Importance.max : Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound(kind.sound),
          color: StatusEdge.of(tone, Brightness.light),
          category: kind == NotificationKind.chat ? AndroidNotificationCategory.message : null,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: jsonEncode({'id': message.id, 'related_type': message.relatedType, 'related_id': message.relatedId}),
    );
  }
}
