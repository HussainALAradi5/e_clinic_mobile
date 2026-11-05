import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';

part 'staff_paths_staff_page.dart';
part 'staff_paths_staff_tab.dart';

/// Staff routes (the staff part of the app; same paths as the mobile docs).
abstract final class StaffPaths {
  static const today = '/today';
  static const scan = '/scan';
  static const sessions = '/clinic/sessions';
  static const approvals = '/approvals';
  static const more = '/more';
  static const signature = '/account/signature';
  static const monthSummary = '/accounting/month-summary';
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
  static const requests = '/hr/requests';
  static const inbox = '/inbox';
  static const tickets = '/support/tickets';
  static const newTicket = '/support/tickets/new';
  static const ticketPattern = '/support/tickets/:id';
  static const chats = '/chat';
  static const chatPattern = '/chat/:id';

  static String appointment(String id) => '/clinic/appointments/$id';

  static String patient(String id) => '$patients/$id';

  static String bookFor(String patientId) => '$book?patient=$patientId';

  static String order(String id) => '$orders/$id';

  static String dispenseFor(String prescriptionId) => '$dispense/$prescriptionId';

  static String ticket(String id) => '$tickets/$id';

  static String chat(String id) => '$chats/$id';

  /// The staff page a notification opens, by its related record (null when the app has no page for it).
  static String? forNotification(String? type, String? id) => switch ((type, id)) {
    ('support_ticket', final String id) => ticket(id),
    ('conversation', final String id) => chat(id),
    ('appointment', final String id) => appointment(id),
    ('clinical_order', final String id) => order(id),
    ('patient', final String id) => patient(id),
    ('leave_request', _) => leaves,
    ('staff_request', _) => requests,
    ('attendance', _) => clock,
    // Waiting for a decision (or decided): the approvals list.
    ('expense' || 'refund' || 'payment', _) => approvals,
    ('prescription', final String id) => dispenseFor(id),
    ('dispensation', _) => dispensations,
    ('treatment', _) => sessions,
    _ => null,
  };

  static const _roots = [today, scan, approvals, more, inbox, '/clinic', '/hr', '/pharmacy', '/support', chats];

  /// The path is part of the staff area.
  static bool owns(String path) => _roots.any((root) => _under(path, root));

  /// Pages outside the tabs and the right each needs, the most specific path first (same expressions as the
  /// server routes, which check again).
  static final _guards = <(String, String)>[
    (book, 'appointments.create'),
    (newLeave, 'leaves.create & leaves.request'),
    (newTicket, 'tickets.create'),
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
