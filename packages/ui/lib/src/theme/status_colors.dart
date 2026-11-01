import 'package:flutter/material.dart';

/// Badge colour of any enum value, the same as the web: hand-picked where a value carries meaning (completed is always
/// green), otherwise a stable colour from the value's place in the enum.
enum StatusTone { grey, blue, teal, green, amber, red, redOutline, orange, cyan, indigo, purple, pink }

abstract final class StatusColors {
  /// Same table as the web client (`status-tones.constants.ts`); keep the two in step.
  static const _tones = <String, Map<String, StatusTone>>{
    'GenericStatus': {
      'pending': StatusTone.grey,
      'in_progress': StatusTone.blue,
      'completed': StatusTone.green,
      'cancelled': StatusTone.redOutline,
    },
    'TreatmentPriority': {'medium': StatusTone.grey, 'high': StatusTone.amber, 'urgent': StatusTone.red},
    'TreatmentType': {
      'physiotherapy': StatusTone.teal,
      'rehabilitation': StatusTone.green,
      'wound_care': StatusTone.orange,
      'injection': StatusTone.blue,
      'infusion': StatusTone.cyan,
      'dialysis': StatusTone.indigo,
      'respiratory_therapy': StatusTone.purple,
      'laser': StatusTone.pink,
      'dental': StatusTone.amber,
      'other': StatusTone.grey,
    },
    'AppointmentType': {
      'consultation': StatusTone.blue,
      'follow_up': StatusTone.teal,
      'procedure': StatusTone.purple,
      'emergency': StatusTone.red,
      'teleconsultation': StatusTone.cyan,
      'treatment_session': StatusTone.indigo,
    },
    'AppointmentSource': {
      'walk_in': StatusTone.orange,
      'phone': StatusTone.blue,
      'portal': StatusTone.teal,
      'referral': StatusTone.purple,
    },
    'AuditAction': {
      'created': StatusTone.green,
      'updated': StatusTone.blue,
      'deleted': StatusTone.red,
      'restored': StatusTone.teal,
      'status_changed': StatusTone.indigo,
      'login': StatusTone.cyan,
      'logout': StatusTone.grey,
      'login_failed': StatusTone.red,
      'password_changed': StatusTone.amber,
      'permission_changed': StatusTone.amber,
      'exported': StatusTone.purple,
      'posted': StatusTone.green,
      'reversed': StatusTone.redOutline,
      'approved': StatusTone.green,
    },
    'BalanceSide': {'debit': StatusTone.blue, 'credit': StatusTone.teal},
    'TransactionDirection': {'in': StatusTone.green, 'out': StatusTone.red, 'internal': StatusTone.grey},
    'LoginFailureReason': {
      'invalid_credentials': StatusTone.red,
      'account_locked': StatusTone.red,
      'account_inactive': StatusTone.grey,
      'too_many_attempts': StatusTone.amber,
      'invalid_2fa_code': StatusTone.amber,
    },
    'Gender': {'male': StatusTone.blue, 'female': StatusTone.pink},
    'ApprovalStatus': {
      'draft': StatusTone.grey,
      'pending': StatusTone.grey,
      'approved': StatusTone.green,
      'rejected': StatusTone.red,
      'cancelled': StatusTone.redOutline,
    },
    'AppointmentStatus': {
      'pending': StatusTone.grey,
      'confirmed': StatusTone.blue,
      'checked_in': StatusTone.teal,
      'in_progress': StatusTone.blue,
      'completed': StatusTone.green,
      'cancelled': StatusTone.redOutline,
      'no_show': StatusTone.red,
      'rescheduled': StatusTone.amber,
    },
    'CashSessionStatus': {'open': StatusTone.blue, 'closing': StatusTone.amber, 'closed': StatusTone.green},
    'EmployeeStatus': {'active': StatusTone.green, 'suspended': StatusTone.amber, 'terminated': StatusTone.red},
    'ExpiryStatus': {'ok': StatusTone.green, 'expiring': StatusTone.amber, 'expired': StatusTone.red},
    'AttendanceStatus': {
      'present': StatusTone.green,
      'late': StatusTone.amber,
      'absent': StatusTone.red,
      'half_day': StatusTone.amber,
      'on_leave': StatusTone.blue,
      'holiday': StatusTone.teal,
      'weekend': StatusTone.grey,
    },
    'PayrollStatus': {
      'draft': StatusTone.grey,
      'calculated': StatusTone.blue,
      'approved': StatusTone.teal,
      'paid': StatusTone.green,
      'cancelled': StatusTone.redOutline,
    },
    'FileScanStatus': {'clean': StatusTone.green, 'infected': StatusTone.red},
    'FiscalStatus': {'open': StatusTone.green, 'closed': StatusTone.grey, 'locked': StatusTone.red},
    'JournalEntryStatus': {'draft': StatusTone.grey, 'posted': StatusTone.green, 'reversed': StatusTone.redOutline},
    'InvoiceStatus': {
      'issued': StatusTone.blue,
      'partially_paid': StatusTone.amber,
      'paid': StatusTone.green,
      'cancelled': StatusTone.redOutline,
    },
    'NotificationStatus': {
      'sent': StatusTone.blue,
      'delivered': StatusTone.green,
      'failed': StatusTone.red,
      'cancelled': StatusTone.redOutline,
    },
    'PaymentStatus': {'completed': StatusTone.green, 'voided': StatusTone.red},
    'StockMovementType': {
      'receipt': StatusTone.green,
      'dispense': StatusTone.blue,
      'return': StatusTone.teal,
      'adjustment': StatusTone.amber,
      'expiry_writeoff': StatusTone.red,
    },
    'UserStatus': {'active': StatusTone.green, 'locked': StatusTone.red},
    'TicketConfirmation': {
      'awaiting': StatusTone.amber,
      'confirmed': StatusTone.green,
      'declined': StatusTone.red,
    },
    'TicketCategory': {
      'technical': StatusTone.indigo,
      'access': StatusTone.purple,
      'equipment': StatusTone.orange,
      'data': StatusTone.cyan,
      'other': StatusTone.grey,
    },
    'ConversationType': {'direct': StatusTone.blue, 'group': StatusTone.purple},
    'ParticipantRole': {'admin': StatusTone.teal, 'member': StatusTone.grey},
  };

  /// Handed out in option order to enums without a hand-picked map; red and grey stay reserved for meaning.
  static const _category = [
    StatusTone.blue,
    StatusTone.teal,
    StatusTone.purple,
    StatusTone.orange,
    StatusTone.cyan,
    StatusTone.pink,
    StatusTone.indigo,
    StatusTone.amber,
    StatusTone.green,
  ];

  /// [order] is the enum's values from the catalog, used when the enum has no hand-picked map.
  static StatusTone tone(String enumName, String value, {List<String> order = const []}) {
    final fixed = _tones[enumName];
    if (fixed != null) return fixed[value] ?? StatusTone.grey;
    final index = order.indexOf(value);
    return index < 0 ? StatusTone.grey : _category[index % _category.length];
  }

  /// (background, foreground, border) for a tone in the current brightness.
  static ({Color background, Color foreground, Color? border}) of(StatusTone tone, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    (Color, Color) pair(MaterialColor c, {bool deep = false}) =>
        dark ? (c.shade900.withValues(alpha: 0.5), c.shade100) : (c.shade100, deep ? c.shade900 : c.shade800);
    final (background, foreground) = switch (tone) {
      StatusTone.grey =>
        dark ? (const Color(0xFF27272A), const Color(0xFFE4E4E7)) : (const Color(0xFFF4F4F5), const Color(0xFF3F3F46)),
      StatusTone.blue => pair(Colors.blue),
      StatusTone.teal => pair(Colors.teal),
      StatusTone.green => pair(Colors.green),
      StatusTone.amber => pair(Colors.amber, deep: true),
      StatusTone.red => pair(Colors.red),
      StatusTone.orange => pair(Colors.orange, deep: true),
      StatusTone.cyan => pair(Colors.cyan, deep: true),
      StatusTone.indigo => pair(Colors.indigo),
      StatusTone.purple => pair(Colors.purple),
      StatusTone.pink => pair(Colors.pink),
      StatusTone.redOutline => (Colors.transparent, dark ? Colors.red.shade300 : Colors.red.shade700),
    };
    return (
      background: background,
      foreground: foreground,
      border: tone == StatusTone.redOutline ? (dark ? Colors.red.shade400 : Colors.red.shade300) : null,
    );
  }
}
