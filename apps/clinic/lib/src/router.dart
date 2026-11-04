import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/routes/portal_paths.dart';
import 'config/routes/staff_paths.dart';
import 'screens/portal/appointments_screen.dart';
import 'screens/portal/booking_screen.dart';
import 'screens/portal/home_screen.dart';
import 'screens/portal/invoices_screen.dart';
import 'screens/portal/notifications_screen.dart';
import 'screens/portal/prescriptions_screen.dart';
import 'screens/portal/profile_screen.dart';
import 'screens/portal/results_screen.dart';
import 'screens/portal/sick_leaves_screen.dart';
import 'screens/portal/treatments_screen.dart';
import 'screens/staff/appointment_detail_screen.dart';
import 'screens/staff/approvals_screen.dart';
import 'screens/staff/book_screen.dart';
import 'screens/staff/calendar_screen.dart';
import 'screens/staff/chat_screen.dart';
import 'screens/staff/chats_screen.dart';
import 'screens/staff/clock_screen.dart';
import 'screens/staff/dispensations_screen.dart';
import 'screens/staff/dispense_screen.dart';
import 'screens/staff/inbox_screen.dart';
import 'screens/staff/leaves_screen.dart';
import 'screens/staff/month_summary_screen.dart';
import 'screens/staff/more_screen.dart';
import 'screens/staff/new_leave_screen.dart';
import 'screens/staff/new_ticket_screen.dart';
import 'screens/staff/order_detail_screen.dart';
import 'screens/staff/orders_screen.dart';
import 'screens/staff/patient_detail_screen.dart';
import 'screens/staff/patients_screen.dart';
import 'screens/staff/pharmacy_queue_screen.dart';
import 'screens/staff/scan_screen.dart';
import 'screens/staff/sessions_screen.dart';
import 'screens/staff/signature_screen.dart';
import 'screens/staff/staff_requests_screen.dart';
import 'screens/staff/ticket_detail_screen.dart';
import 'screens/staff/tickets_screen.dart';
import 'screens/staff/today_screen.dart';
import 'widgets/portal/shell/patient_shell.dart';
import 'widgets/staff/shell/staff_shell.dart';

/// Where an account starts: patients on their home, staff on today's schedule.
String homeFor(User? user) => (user?.isPatient ?? false) ? PortalPaths.home : StaffPaths.today;

/// One app, two experiences: after sign-in the account type picks the patient or the staff screens, as on the web.
/// Patients never reach staff paths and staff never reach patient paths; staff tabs and pages also follow their
/// rights. (Hiding is a convenience — the server checks every request.)
String? areaRedirect(User user, String path, bool Function(String expression) can) {
  if (path == '/') return homeFor(user);
  if (user.isPatient ? StaffPaths.owns(path) : PortalPaths.owns(path)) return homeFor(user);
  if (!user.isPatient && StaffPaths.owns(path) && !can(StaffPaths.accessFor(path))) return StaffPaths.today;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  GoRoute page(String path, Widget screen) => GoRoute(path: path, builder: (_, _) => screen);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (_, state) {
      final user = ref.read(currentUserProvider);
      final auth = authRedirect(ref, state, home: homeFor(user));
      if (auth != null || user == null) return auth;
      return areaRedirect(user, state.matchedLocation, ref.read(accessProvider).can);
    },
    routes: [
      ...authRoutes(),
      GoRoute(path: '/', redirect: (_, _) => homeFor(ref.read(currentUserProvider))),

      // Patients.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => PatientShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [page(PortalPaths.home, const HomeScreen())]),
          StatefulShellBranch(routes: [page(PortalPaths.visits, const AppointmentsScreen())]),
          StatefulShellBranch(routes: [page(PortalPaths.results, const ResultsScreen())]),
          StatefulShellBranch(routes: [page(PortalPaths.invoices, const InvoicesScreen())]),
          StatefulShellBranch(routes: [page(PortalPaths.profile, const ProfileScreen())]),
        ],
      ),
      page(PortalPaths.book, const BookingScreen()),
      page(PortalPaths.treatments, const TreatmentsScreen()),
      page(PortalPaths.prescriptions, const PrescriptionsScreen()),
      page(PortalPaths.sickLeaves, const SickLeavesScreen()),
      page(PortalPaths.messages, const NotificationsScreen()),

      // Staff — one branch per StaffTab, in the same order.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => StaffShell(shell: shell),
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
      page(StaffPaths.patients, const PatientsScreen()),
      GoRoute(
        path: StaffPaths.patientPattern,
        builder: (_, state) => PatientDetailScreen(id: state.pathParameters['id']!),
      ),
      page(StaffPaths.calendar, const CalendarScreen()),
      GoRoute(
        path: StaffPaths.book,
        builder: (_, state) => BookScreen(patientId: state.uri.queryParameters['patient']),
      ),
      page(StaffPaths.orders, const OrdersScreen()),
      GoRoute(
        path: StaffPaths.orderPattern,
        builder: (_, state) => OrderDetailScreen(id: state.pathParameters['id']!),
      ),
      page(StaffPaths.dispense, const PharmacyQueueScreen()),
      GoRoute(
        path: StaffPaths.dispensePattern,
        builder: (_, state) => DispenseScreen(id: state.pathParameters['id']!),
      ),
      page(StaffPaths.dispensations, const DispensationsScreen()),
      page(StaffPaths.leaves, const LeavesScreen()),
      page(StaffPaths.requests, const StaffRequestsScreen()),
      page(StaffPaths.newLeave, const NewLeaveScreen()),
      page(StaffPaths.inbox, const InboxScreen()),
      page(StaffPaths.signature, const SignatureScreen()),
      page(StaffPaths.monthSummary, const MonthSummaryScreen()),
      page(StaffPaths.chats, const ChatsScreen()),
      GoRoute(
        path: StaffPaths.chatPattern,
        builder: (_, state) => ChatScreen(id: state.pathParameters['id']!),
      ),
      page(StaffPaths.tickets, const TicketsScreen()),
      // `new` before `:id`, so it is not read as a ticket id.
      page(StaffPaths.newTicket, const NewTicketScreen()),
      GoRoute(
        path: StaffPaths.ticketPattern,
        builder: (_, state) => TicketDetailScreen(id: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
