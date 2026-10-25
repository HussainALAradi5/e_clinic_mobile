import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/portal_actions.dart';
import '../application/portal_providers.dart';

/// `/prescriptions` — medicines with how to take them; open ones carry the code for the pharmacy.
class PrescriptionsScreen extends ConsumerWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('My prescriptions')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(prescriptionsProvider.future),
      child: AsyncBody(
        value: ref.watch(prescriptionsProvider),
        onRetry: () => ref.invalidate(prescriptionsProvider),
        data: (list) => list.isEmpty
            ? ListView(
                children: const [
                  EmptyState(
                    icon: Icons.medication_outlined,
                    title: 'No prescriptions',
                    message: 'Medicines your doctor prescribes show here, with the code for the pharmacy.',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _PrescriptionCard(rx: list[i]),
              ),
      ),
    ),
  );
}

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.rx});

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
          ],
        ),
      ),
    );
  }
}
