import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Staff routes (the staff part of the app; same paths as the mobile docs).
abstract final class StaffPaths {
  static const today = '/today';
  static const scan = '/scan';
  static const sessions = '/clinic/sessions';
  static const approvals = '/approvals';
  static const more = '/more';
  static const clock = '/hr/attendance/clock';
  static const appointmentPattern = '/clinic/appointments/:id';
  static const patients = '/clinic/patients';
  static const patientPattern = '/clinic/patients/:id';
  static const calendar = '/clinic/calendar';

  /// Booking wizard; `?patient=<id>` starts it with that patient chosen.
  static const book = '/clinic/book';
  static const orders = '/clinic/clinical-orders';
  static const orderPattern = '/clinic/clinical-orders/:id';
  static const dispense = '/pharmacy/dispense';
  static const dispensePattern = '/pharmacy/dispense/:id';
  static const dispensations = '/pharmacy/dispensing';
  static const leaves = '/hr/leaves';
  static const newLeave = '/hr/leaves/new';

  static String appointment(String id) => '/clinic/appointments/$id';

  static String patient(String id) => '$patients/$id';

  static String bookFor(String patientId) => '$book?patient=$patientId';

  static String order(String id) => '$orders/$id';

  static String dispenseFor(String prescriptionId) => '$dispense/$prescriptionId';

  static const _roots = [today, scan, approvals, more, '/clinic', '/hr', '/pharmacy'];

  /// The path is part of the staff area.
  static bool owns(String path) => _roots.any((root) => _under(path, root));

  /// Pages outside the tabs and the right each needs, the most specific path first (same expressions as the
  /// server routes, which check again).
  static final _guards = <(String, String)>[
    (book, 'appointments.create'),
    (newLeave, 'leaves.create & leaves.request'),
    ('/clinic/appointments', 'appointments.read_all | appointments.read_own'),
    for (final page in StaffPage.values) (page.path, page.access),
  ];

  /// The permission expression a staff path needs: its page's, else its tab's (Today for anything else).
  static String accessFor(String path) {
    for (final (root, access) in _guards) {
      if (_under(path, root)) return access;
    }
    return StaffTab.of(path).access;
  }

  static bool _under(String path, String root) => path == root || path.startsWith('$root/');
}

/// Bottom-navigation tabs in order; a tab shows only when the user holds its permission expression.
/// Today and More are open to every staff member, so the bar always has at least two tabs.
enum StaffTab {
  today(StaffPaths.today, 'Today', Icons.today_outlined, Icons.today_rounded, Access.authenticated),
  scan(
    StaffPaths.scan,
    'Scan',
    Icons.qr_code_scanner_rounded,
    Icons.qr_code_scanner_rounded,
    '(codes.read_all | codes.read_own) & codes.scan',
  ),
  sessions(
    StaffPaths.sessions,
    'Sessions',
    Icons.self_improvement_outlined,
    Icons.self_improvement_rounded,
    'appointments.treat',
  ),
  approvals(
    StaffPaths.approvals,
    'Approvals',
    Icons.fact_check_outlined,
    Icons.fact_check_rounded,
    'refunds.approve | expenses.approve | leaves.approve | attendance.approve_overtime',
  ),
  more(StaffPaths.more, 'More', Icons.menu_rounded, Icons.menu_open_rounded, Access.authenticated);

  const StaffTab(this.path, this.label, this.icon, this.selectedIcon, this.access);

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String access;

  /// Tabs this user may open, in bar order.
  static List<StaffTab> visible(Access access) => [
    for (final tab in values)
      if (access.can(tab.access)) tab,
  ];

  /// The tab a location belongs to (Today for anything outside the other tabs).
  static StaffTab of(String location) => values.firstWhere(
    (tab) => tab != today && (location == tab.path || location.startsWith('${tab.path}/')),
    orElse: () => today,
  );
}

/// Work pages linked from More, in menu order; a link shows only when the user holds its permission expression.
enum StaffPage {
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
