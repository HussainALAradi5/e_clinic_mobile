import 'dart:async';

import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/routes/portal_paths.dart';
import 'config/routes/staff_paths.dart';
import 'controllers/staff/schedule_cache.dart';
import 'router.dart';

class EClinicApp extends ConsumerWidget {
  const EClinicApp({super.key});

  /// A tapped phone notification: marks it read and opens its record (else the inbox). Waits while nobody is signed
  /// in yet (a tap that started the app), and is used once.
  static void _openTapped(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final tap = ref.read(notificationTapsProvider.notifier).take();
    if (tap == null) return;
    unawaited(ref.read(notificationRepositoryProvider).markRead(tap.id).then((_) {}, onError: (Object _) {}));
    final path = user.isPatient
        ? PortalPaths.forRelated(tap.relatedType) ?? PortalPaths.messages
        : StaffPaths.forNotification(tap.relatedType, tap.relatedId) ?? StaffPaths.inbox;
    ref.read(routerProvider).go(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentUserProvider, (previous, next) {
      // Signing out (or a revoked session) leaves nothing of the clinic's day on the phone.
      if (previous != null && next == null) ref.read(scheduleCacheProvider).clear();
      // A different account starts from a clean stack: Back must never return to the last user's pages (the router
      // checks the area on navigation, not on Back).
      if (previous?.id != next?.id) ref.read(routerProvider).go(next == null ? AuthPaths.login : homeFor(next));
      _openTapped(ref);
    });
    // New inbox messages pop up on the phone while the app runs (when the person's switch is on).
    ref.watch(inboxWatcherProvider);
    ref.listen(notificationTapsProvider, (_, _) => _openTapped(ref));
    // Set up the tray early so a tap that started the app is handled.
    unawaited(ref.read(systemNotificationsProvider).init());
    return AppLockScope(
      child: MaterialApp.router(
        title: 'e-Clinic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.watch(themeModeProvider),
        routerConfig: ref.watch(routerProvider),
        scaffoldMessengerKey: AppSnack.messengerKey,
      ),
    );
  }
}
