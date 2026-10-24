import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

/// Staff app routes (same paths as the mobile docs).
abstract final class StaffPaths {
  static const today = '/';
  static const scan = '/scan';
  static const sessions = '/clinic/sessions';
  static const approvals = '/approvals';
  static const more = '/more';
  static const clock = '/hr/attendance/clock';
  static const appointmentPattern = '/clinic/appointments/:id';

  static String appointment(String id) => '/clinic/appointments/$id';
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
