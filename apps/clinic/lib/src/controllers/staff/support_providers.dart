import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  (value: 'support_ticket', label: 'Support'),
  (value: 'appointment', label: 'Appointments'),
  (value: 'clinical_order', label: 'Orders'),
  (value: 'conversation', label: 'Chat'),
  (value: 'leave_request', label: 'Leave'),
  (value: 'payslip', label: 'Payslips'),
];
