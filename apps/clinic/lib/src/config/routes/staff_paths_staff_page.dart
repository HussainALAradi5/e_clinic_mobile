part of 'staff_paths.dart';

/// Work pages linked from More, in menu order; a link shows only when the user holds its permission expression.
enum StaffPage {
  inbox(StaffPaths.inbox, 'Notifications', Icons.notifications_outlined, Access.authenticated),
  chat(StaffPaths.chats, 'Chat', Icons.forum_outlined, 'chat.read_own | chat.read_all'),
  tickets(StaffPaths.tickets, 'Support tickets', Icons.support_agent_rounded, 'tickets.read_own | tickets.read_all'),
  patients(StaffPaths.patients, 'Patient files', Icons.folder_shared_outlined, 'patients.read_all | patients.read_own'),
  calendar(
    StaffPaths.calendar,
    'Calendar & booking',
    Icons.calendar_month_outlined,
    'appointments.read_all | appointments.read_own',
  ),
  orders(StaffPaths.orders, 'Order work list', Icons.biotech_outlined, 'orders.read_all | orders.read_own'),
  dispense(StaffPaths.dispense, 'Pharmacy queue', Icons.medication_outlined, 'dispensing.create & dispensing.dispense'),
  dispensations(
    StaffPaths.dispensations,
    'Dispensed medicines',
    Icons.inventory_2_outlined,
    'dispensing.read_all | dispensing.read_own',
  ),
  leaves(StaffPaths.leaves, 'My leave', Icons.beach_access_outlined, 'leaves.read_all | leaves.read_own'),
  requests(
    StaffPaths.requests,
    'Late & overtime requests',
    Icons.more_time_rounded,
    'staff_requests.read_own | staff_requests.read_all',
  ),
  clock(StaffPaths.clock, 'Clock in / out', Icons.schedule_rounded, 'attendance.self');

  const StaffPage(this.path, this.label, this.icon, this.access);

  final String path;
  final String label;
  final IconData icon;
  final String access;

  /// Pages this user may open, in menu order.
  static List<StaffPage> visible(Access access) => [
    for (final page in values)
      if (access.can(page.access)) page,
  ];
}
