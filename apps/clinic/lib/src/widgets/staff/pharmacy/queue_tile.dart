import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// A prescription waiting at the pharmacy: patient, medicines, doctor and age; a lock mark for controlled drugs.
class QueueTile extends StatelessWidget {
  const QueueTile({super.key, required this.prescription, required this.onTap});

  final Prescription prescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final p = prescription;
    final controlled = p.items.any((i) => i.medication.isControlled);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.patient?.fullName ?? p.code, style: theme.textTheme.titleMedium),
                    Text(
                      [p.code, if (p.patient?.code != null) p.patient!.code!].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.items.map((i) => i.medication.name).join(', '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusChip(enumName: 'GenericStatus', value: p.status),
                        if (controlled)
                          const Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(Icons.lock_outline_rounded, size: 16),
                            label: Text('Controlled'),
                          ),
                        Text(
                          [
                            if (p.doctor != null) p.doctor!.fullName,
                            if (p.createdAt != null) ClinicClock.ago(p.createdAt!),
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
