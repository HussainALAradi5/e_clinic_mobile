import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_controller.dart';
import 'phone_notifications_controller.dart';

/// While the app runs (in front or in the background) and the switch is on, new inbox messages also appear as
/// phone notifications. Without a push service (Firebase) a closed app shows nothing until it is opened.
/// The first look after sign-in only remembers where the inbox is, so old messages do not pop up.
class InboxWatcher {
  InboxWatcher(this._ref, this._userId);

  static const every = Duration(seconds: 30);
  static const _maxPerLook = 5;

  final Ref _ref;
  final String _userId;
  Timer? _timer;

  String get _prefKey => 'ec.notified_until.$_userId';

  void start() {
    // The phone's own permission (Android 13+): asked once, the first time the switch is on.
    unawaited(_ref.read(systemNotificationsProvider).requestPermission().catchError((Object _) => false));
    unawaited(_look());
    _timer = Timer.periodic(every, (_) => _look());
  }

  void stop() => _timer?.cancel();

  Future<void> _look() async {
    try {
      final prefs = _ref.read(preferencesProvider);
      final page = await _ref
          .read(notificationRepositoryProvider)
          .inbox(const ListQuery(perPage: 10, sort: ['-createdAt']), read: InboxRead.unread);
      final seen = DateTime.tryParse(prefs.getString(_prefKey) ?? '');
      final newest = page.items
          .map((n) => n.createdAt)
          .fold<DateTime?>(seen, (latest, at) => latest == null || at.isAfter(latest) ? at : latest);
      if (seen != null) {
        final fresh = page.items.where((n) => n.createdAt.isAfter(seen)).take(_maxPerLook);
        for (final n in fresh) {
          await _ref
              .read(systemNotificationsProvider)
              .show(id: n.id.hashCode, kind: n.kind, title: n.subject ?? 'e-Clinic', body: n.body);
        }
      }
      await prefs.setString(_prefKey, (newest ?? DateTime.now()).toIso8601String());
    } catch (_) {
      // Offline or signed out meanwhile: the next look tries again.
    }
  }
}

/// Runs an [InboxWatcher] while someone is signed in and their switch is on; the app watches this at its root.
final inboxWatcherProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);
  final on = ref.watch(phoneNotificationsProvider).value ?? false;
  if (user == null || !on) return;
  final watcher = InboxWatcher(ref, user.id)..start();
  ref.onDispose(watcher.stop);
});
