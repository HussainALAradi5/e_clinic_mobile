/// The button to a notification's place, by its related record ("Open result"), and the message sheet's words.
abstract final class NotificationLinkText {
  static const message = 'Message';
  static const close = 'Close';

  static String openFor(String? relatedType) => switch (relatedType) {
    'appointment' => 'Open appointment',
    'treatment' => 'Open treatment',
    'clinical_order' => 'Open result',
    'prescription' => 'Open prescription',
    'dispensation' => 'Open dispensing',
    'sick_leave' => 'Open sick leave',
    'invoice' => 'Open invoice',
    'payment' => 'Open payments',
    'refund' => 'Open refunds',
    'expense' => 'Open expense',
    'leave_request' => 'Open leave request',
    'staff_request' => 'Open request',
    'attendance' => 'Open my attendance',
    'patient' => 'Open patient',
    'support_ticket' => 'Open ticket',
    'conversation' => 'Open chat',
    _ => 'Open',
  };
}
