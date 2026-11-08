import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/status_colors.dart';
import 'status_badge.dart';

/// Coloured enum badge (same colours as the web); the label is always written, never colour alone.
class StatusChip extends ConsumerWidget {
  const StatusChip({super.key, required this.enumName, required this.value, this.label});

  /// Server enum name, e.g. `AppointmentStatus`.
  final String enumName;

  /// An enum value or its wire string.
  final Object value;

  /// The label the server sent with the row; the enum catalog's when null.
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wire = wireValue(value);
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return StatusBadge(
      label: label ?? catalog.label(enumName, wire),
      tone: StatusColors.tone(enumName, wire, order: catalog.values(enumName)),
    );
  }
}
