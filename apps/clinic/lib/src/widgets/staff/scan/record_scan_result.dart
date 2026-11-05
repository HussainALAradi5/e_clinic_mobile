import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/scan_text.dart';
import 'scan_result_title.dart';

class RecordScanResult extends ConsumerWidget {
  const RecordScanResult({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final facts = [
      for (final MapEntry(:key, :value) in result.summary.entries)
        if (key != 'code' && value != null && value is! Map && value is! List)
          (label: humanise(key), value: _value(key, '$value')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScanResultTitle(title: humanise(result.entity), code: result.code),
        if (facts.isNotEmpty) Card(child: FactList(facts: facts)),
        const InfoNote(icon: Icons.verified_outlined, text: ScanText.genuine),
      ],
    );
  }

  /// Dates and instants read as clinic dates; everything else as sent (statuses humanised).
  static String _value(String key, String value) {
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) return ClinicClock.date(value);
    final instant = DateTime.tryParse(value);
    if (instant != null && value.contains('T')) return ClinicClock.dateTime(instant);
    if (key == 'status' || key == 'type' || key == 'kind' || key == 'method') return humanise(value);
    return value;
  }
}
