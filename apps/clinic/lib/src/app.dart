import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'staff/application/schedule_cache.dart';

class EClinicApp extends ConsumerWidget {
  const EClinicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Signing out (or a revoked session) leaves nothing of the clinic's day on the phone.
    ref.listen(currentUserProvider, (previous, next) {
      if (previous != null && next == null) ref.read(scheduleCacheProvider).clear();
    });
    return AppLockScope(
      child: MaterialApp.router(
        title: 'e-Clinic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        routerConfig: ref.watch(routerProvider),
      ),
    );
  }
}
