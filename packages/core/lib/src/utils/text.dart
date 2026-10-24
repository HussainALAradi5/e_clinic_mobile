/// `scheduledDate` → `scheduled_date`, `checkedIn` → `checked_in`.
String snakeCase(String value) =>
    value.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]!.toLowerCase()}');

/// `in_progress` → `In progress` (fallback label of an enum value the catalogue does not know).
String humanise(String value) {
  final words = value.replaceAll('_', ' ').trim();
  return words.isEmpty ? words : words[0].toUpperCase() + words.substring(1);
}

/// Value of an enum on the wire: `AppointmentStatus.checkedIn` → `checked_in`; lists are comma-separated.
String wireValue(Object value) => switch (value) {
  final Enum e => snakeCase(e.name),
  final List<Object?> list => list.map((v) => v == null ? '' : wireValue(v)).join(','),
  _ => value.toString(),
};

/// Initials for an avatar: `Rana Saleh` → `RS`.
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return (first + last).toUpperCase();
}
