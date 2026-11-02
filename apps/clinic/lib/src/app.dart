import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/staff/schedule_cache.dart';
import 'router.dart';

class EClinicApp extends ConsumerWidget {
  const EClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentUserProvider, (previous, next) {
      // Signing out (or a revoked session) leaves nothing of the clinic's day on the phone.
      if (previous != null && next == null) ref.read(scheduleCacheProvider).clear();
      // A different account starts from a clean stack: Back must never return to the last user's pages (the router
      // checks the area on navigation, not on Back).
      if (previous?.id != next?.id) ref.read(routerProvider).go(next == null ? AuthPaths.login : homeFor(next));
    });
    return AppLockScope(
      child: MaterialApp.router(
        title: 'e-Clinic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ref.watch(themeModeProvider),
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
