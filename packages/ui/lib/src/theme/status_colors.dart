import 'package:flutter/material.dart';

/// Badge colour of any enum value, the same as the web: hand-picked where a value carries meaning (completed is always
/// green), otherwise a stable colour from the value's place in the enum.
enum StatusTone { grey, blue, teal, green, amber, red, redOutline, orange, cyan, indigo, purple, pink }

abstract final class StatusColors {
  static const _tones = <String, Map<String, StatusTone>>{
    'GenericStatus': {
      'pending': StatusTone.grey,
      'in_progress': StatusTone.blue,
      'completed': StatusTone.green,
      'cancelled': StatusTone.redOutline,
    },
    'TreatmentPriority': {'medium': StatusTone.grey, 'high': StatusTone.amber, 'urgent': StatusTone.red},
    // One colour per kind of treatment (same as the web).
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
    'InvoiceStatus': {
      'issued': StatusTone.blue,
      'partially_paid': StatusTone.amber,
      'paid': StatusTone.green,
      'cancelled': StatusTone.redOutline,
    },
    'PaymentStatus': {'completed': StatusTone.green, 'voided': StatusTone.red},
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
