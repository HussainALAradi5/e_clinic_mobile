import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/staff/ticket_text.dart';

/// Unread notifications of the signed-in staff member (the count on More › Notifications).
final staffUnreadProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(notificationRepositoryProvider).unreadCount(),
);

/// One support ticket with its replies.
final ticketProvider = FutureProvider.autoDispose.family<SupportTicket, String>(
  (ref, id) => ref.watch(ticketRepositoryProvider).get(id),
);

/// What "about" filters the inbox offers (related record aliases on the server).
const inboxTopics = <({String value, String label})>[
  (value: 'support_ticket', label: TicketText.topicSupport),
  (value: 'appointment', label: TicketText.topicAppointments),
  (value: 'clinical_order', label: TicketText.topicOrders),
  (value: 'conversation', label: TicketText.topicChat),
  (value: 'leave_request', label: TicketText.topicLeave),
  (value: 'payslip', label: TicketText.topicPayslips),
];
