import 'package:e_clinic_data/data.dart';

import '../../constants/staff/activity_log_text.dart';

/// What an event changed as a plain phrase: `Email from a@x.com to b@x.com; Phone set to 3333`. Empty when no field
/// changed.
String describeActivityChanges(List<ActivityChange> changes) => changes.map(_describe).join('; ');

String _describe(ActivityChange change) => switch ((_shown(change.oldValue), _shown(change.newValue))) {
  (final String from, final String to) => ActivityLogText.changed(change.label, from, to),
  (null, final String to) => ActivityLogText.set(change.label, to),
  (final String from, null) => ActivityLogText.cleared(change.label, from),
  (null, null) => ActivityLogText.touched(change.label),
};

/// A value as text, or null when it is empty.
String? _shown(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
