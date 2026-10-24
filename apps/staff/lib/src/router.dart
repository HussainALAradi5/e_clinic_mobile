import 'package:e_clinic_features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'screens/appointment_detail_screen.dart';
import 'screens/approvals_screen.dart';
import 'screens/clock_screen.dart';
import 'screens/more_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/today_screen.dart';
import 'staff_paths.dart';
import 'widgets/staff_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  GoRoute page(String path, Widget screen) => GoRoute(path: path, builder: (_, _) => screen);

  final router = GoRouter(
    initialLocation: StaffPaths.today,
    refreshListenable: refresh,
    redirect: (_, state) {
      final auth = authRedirect(ref, state, home: StaffPaths.today);
      if (auth != null || ref.read(sessionProvider).value == null) return auth;
      // A tab the user may not open (link, rights changed) falls back to Today; the server checks every call anyway.
      final tab = StaffTab.of(state.matchedLocation);
      return ref.read(accessProvider).can(tab.access) ? null : StaffPaths.today;
    },
    routes: [
      ...authRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => StaffShell(shell: shell),
        // One branch per StaffTab, in the same order.
        branches: [
          StatefulShellBranch(routes: [page(StaffPaths.today, const TodayScreen())]),
          StatefulShellBranch(routes: [page(StaffPaths.scan, const ScanScreen())]),
          StatefulShellBranch(routes: [page(StaffPaths.sessions, const SessionsScreen())]),
          StatefulShellBranch(routes: [page(StaffPaths.approvals, const ApprovalsScreen())]),
          StatefulShellBranch(routes: [page(StaffPaths.more, const MoreScreen())]),
        ],
      ),
      GoRoute(
        path: StaffPaths.appointmentPattern,
        builder: (_, state) => AppointmentDetailScreen(id: state.pathParameters['id']!),
      ),
      page(StaffPaths.clock, const ClockScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
