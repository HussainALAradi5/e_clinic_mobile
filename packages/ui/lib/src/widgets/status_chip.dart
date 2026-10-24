import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/status_colors.dart';

/// Coloured status badge (same colours as the web); the label is always written, never colour alone.
class StatusChip extends ConsumerWidget {
  const StatusChip({super.key, required this.enumName, required this.value});

  /// Server enum name, e.g. `AppointmentStatus`.
  final String enumName;

  /// An enum value or its wire string.
  final Object value;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wire = wireValue(value);
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    final label = catalog.label(enumName, wire);
    final tone = StatusColors.tone(enumName, wire, order: catalog.values(enumName));
    final colors = StatusColors.of(tone, Theme.of(context).brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: colors.border == null ? null : Border.all(color: colors.border!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: colors.foreground, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
