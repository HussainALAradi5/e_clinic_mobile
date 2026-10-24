import 'package:e_clinic_features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'portal/portal_paths.dart';
import 'portal/screens/appointments_screen.dart';
import 'portal/screens/booking_screen.dart';
import 'portal/screens/home_screen.dart';
import 'portal/screens/invoices_screen.dart';
import 'portal/screens/notifications_screen.dart';
import 'portal/screens/prescriptions_screen.dart';
import 'portal/screens/profile_screen.dart';
import 'portal/screens/results_screen.dart';
import 'portal/screens/treatments_screen.dart';
import 'portal/widgets/patient_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  GoRoute tab(String path, Widget screen) => GoRoute(path: path, builder: (_, _) => screen);

  final router = GoRouter(
    initialLocation: PortalPaths.home,
    refreshListenable: refresh,
    redirect: (_, state) => authRedirect(ref, state, home: PortalPaths.home),
    routes: [
      ...authRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => PatientShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [tab(PortalPaths.home, const HomeScreen())]),
          StatefulShellBranch(routes: [tab(PortalPaths.visits, const AppointmentsScreen())]),
          StatefulShellBranch(routes: [tab(PortalPaths.results, const ResultsScreen())]),
          StatefulShellBranch(routes: [tab(PortalPaths.invoices, const InvoicesScreen())]),
          StatefulShellBranch(routes: [tab(PortalPaths.profile, const ProfileScreen())]),
        ],
      ),
      tab(PortalPaths.book, const BookingScreen()),
      tab(PortalPaths.treatments, const TreatmentsScreen()),
      tab(PortalPaths.prescriptions, const PrescriptionsScreen()),
      tab(PortalPaths.messages, const NotificationsScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
