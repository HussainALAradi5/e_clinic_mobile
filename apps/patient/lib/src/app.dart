import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class PatientApp extends ConsumerWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppLockScope(
    child: MaterialApp.router(
      title: 'e-Clinic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: ref.watch(routerProvider),
    ),
  );
}
