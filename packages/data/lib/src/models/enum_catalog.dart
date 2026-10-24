import 'package:e_clinic_core/core.dart';

/// Labels of every enum from GET /meta/enums (`{ Name: { options: [{ value, label }] } }`).
class EnumCatalog {
  const EnumCatalog(this._labels);

  factory EnumCatalog.fromJson(Object? data) {
    final labels = <String, Map<String, String>>{};
    if (data is Map<String, dynamic>) {
      for (final MapEntry(:key, :value) in data.entries) {
        final options = value is Map<String, dynamic> ? value['options'] : null;
        if (options is! List<dynamic>) continue;
        labels[key] = {
          for (final option in options.whereType<Map<String, dynamic>>())
            '${option['value']}': '${option['label']}',
        };
      }
    }
    return EnumCatalog(labels);
  }

  static const empty = EnumCatalog({});

  final Map<String, Map<String, String>> _labels;

  /// The enum's values in the server's order (gives unmapped enums their badge colours).
  List<String> values(String enumName) => _labels[enumName]?.keys.toList() ?? const [];

  /// Label of a value (`AppointmentStatus`, `checked_in` → `Checked in`); falls back to a humanised value.
  String label(String enumName, Object? value) {
    if (value == null) return '';
    final wire = wireValue(value);
    return _labels[enumName]?[wire] ?? humanise(wire);
  }
}
