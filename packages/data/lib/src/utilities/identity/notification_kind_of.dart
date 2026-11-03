import '../../enums/identity/notification_kind.dart';

/// Templates that need attention now, whatever their area (an abnormal result, an urgent treatment, emergency
/// access to a record).
const _urgent = {'order.abnormal', 'treatment.urgent', 'treatment.attendance_alert', 'patient.emergency_access'};

/// The kind of a message from its server template (`appointment.reminder` → visit). Unknown areas are [system].
NotificationKind notificationKindOf(String template) {
  if (_urgent.contains(template)) return NotificationKind.urgent;
  return switch (template.split('.').first) {
    'appointment' => NotificationKind.visit,
    'treatment' => NotificationKind.treatment,
    'order' => NotificationKind.result,
    'prescription' || 'pharmacy' => NotificationKind.pharmacy,
    'refund' || 'expense' || 'invoice' || 'payment' => NotificationKind.billing,
    'leave' || 'attendance' || 'staff_request' || 'payroll' => NotificationKind.hr,
    'chat' => NotificationKind.chat,
    'ticket' => NotificationKind.support,
    _ => NotificationKind.system,
  };
}
