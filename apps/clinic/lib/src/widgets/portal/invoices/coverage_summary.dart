import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/billing/coverage_text.dart';
import 'total_row.dart';

/// My insurer's part of an invoice and mine (what I pay at the desk), popping in once loaded.
class CoverageSummary extends StatelessWidget {
  const CoverageSummary({super.key, required this.coverage});

  final Coverage coverage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return PopIn(
      from: 0.92,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety_rounded, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    CoverageText.covers(coverage.insurer ?? '', coverage.coveragePercent),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TotalRow(label: CoverageText.insurerPart, value: coverage.insurerShare.label),
            TotalRow(label: CoverageText.myPart, value: coverage.patientShare.label, bold: true),
          ],
        ),
      ),
    );
  }
}
