import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/pharmacy_text.dart';
import '../../../controllers/staff/pharmacy_providers.dart';
import '../../../utilities/staff/formatters.dart';

/// A dispensation on the history list; opens to its medicines and batches, with *Cancel* (stock back, charge
/// reversed) for pharmacists while it stands.
class DispensationCard extends ConsumerWidget {
  const DispensationCard({super.key, required this.dispensation, required this.onChanged});

  final Dispensation dispensation;
  final ValueChanged<Dispensation> onChanged;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final reason = await showReasonSheet(
      context,
      ConfirmConfig(
        title: PharmacyText.cancelTitle(dispensation.code),
        message: PharmacyText.cancelWarning,
        confirmLabel: PharmacyText.cancelDispensation,
        cancelLabel: CommonText.keep,
        danger: true,
      ),
    );
    if (reason == null) return;
    try {
      final updated = await ref.read(dispensationRepositoryProvider).cancel(dispensation.id, reason);
      ref.read(pharmacyVersionProvider.notifier).bump();
      onChanged(updated);
      if (context.mounted) AppSnack.success(context, '${dispensation.code} cancelled.');
    } catch (error) {
      if (context.mounted) AppSnack.error(context, error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final d = dispensation;
    final canCancel =
        d.status == 'completed' && ref.watch(accessProvider).can('dispensing.write & dispensing.dispense');
    return ExpandableCard(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.patient?.fullName ?? d.code, style: theme.textTheme.titleMedium),
          Text(
            [d.code, humanise(d.kind), ClinicClock.dateTime(d.dispensedAt)].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          StatusChip(enumName: 'GenericStatus', value: d.status),
        ],
      ),
      details: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in d.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.medication.name),
                subtitle: item.batch == null
                    ? null
                    : Text(PharmacyText.batch(item.batch!.batchNumber, ClinicClock.date(item.batch!.expiryDate))),
                trailing: Text(
                  '${formatQuantity(double.tryParse(item.quantity) ?? 0)} ${item.medication.unit ?? ''}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            FactList(
              facts: [
                (label: PharmacyText.dispensedBy, value: d.dispensedBy?.fullName),
                (label: PharmacyText.witness, value: d.witness?.fullName),
                (label: CommonText.notes, value: d.notes),
                (label: CommonText.cancelledBecause, value: d.cancellationReason),
              ],
            ),
            if (canCancel)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _cancel(context, ref),
                  icon: const Icon(Icons.undo_rounded),
                  label: const Text(CommonText.cancel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
