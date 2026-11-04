import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../controllers/portal/portal_actions.dart';
import '../../common/document_buttons.dart';

class PrescriptionCard extends StatelessWidget {
  const PrescriptionCard({super.key, required this.rx});

  final Prescription rx;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rx.code, style: theme.textTheme.titleSmall),
                      Text(
                        [
                          if (rx.doctor != null) rx.doctor!.fullName,
                          if (rx.createdAt != null)
                            ClinicClock.date(ClinicClock.isoDate(ClinicClock.local(rx.createdAt!))),
                        ].join(' · '),
                        style: muted,
                      ),
                    ],
                  ),
                ),
                StatusChip(enumName: 'GenericStatus', value: rx.status),
              ],
            ),
            for (final item in rx.items) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.medication_rounded, size: 20, color: scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medication.name,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item.dose}, ${item.frequency} for ${item.durationDays} days',
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (item.instructions != null && item.instructions!.isNotEmpty)
                          Text(item.instructions!, style: muted),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            if (rx.collectable)
              Row(
                children: [
                  Expanded(child: Text('Valid until ${ClinicClock.date(rx.validUntil)}', style: muted)),
                  FilledButton.tonalIcon(
                    onPressed: () => PortalActions.showPrescriptionCode(context, rx),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Pharmacy code'),
                  ),
                ],
              )
            else
              Text(
                rx.status == GenericStatus.completed ? 'Collected' : 'Valid until ${ClinicClock.date(rx.validUntil)}',
                style: muted,
              ),
            const SizedBox(height: 12),
            DocumentButtons(type: DocumentType.prescription, recordId: rx.id),
          ],
        ),
      ),
    );
  }
}
