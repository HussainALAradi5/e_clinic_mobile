import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../constants/billing/package_text.dart';

/// My packages: each with its sessions left as a bar that fills in, its status and validity.
class PackageCard extends StatelessWidget {
  const PackageCard({super.key, required this.packages});

  final List<PatientPackage> packages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.redeem_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Text(PackageText.title, style: theme.textTheme.titleSmall),
              ],
            ),
            for (final p in packages) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(child: Text(p.name, style: theme.textTheme.bodyMedium)),
                  StatusChip(enumName: 'PatientPackageStatus', value: p.status),
                ],
              ),
              const SizedBox(height: 8),
              AppProgressBar(
                value: p.usedShare,
                label: PackageText.left(p.sessionsLeft, p.sessionsTotal),
                color: p.active ? scheme.primary : scheme.outline,
              ),
              const SizedBox(height: 4),
              Text(
                p.expiresOn != null ? PackageText.validUntil(ClinicClock.date(p.expiresOn!)) : PackageText.awaiting,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
