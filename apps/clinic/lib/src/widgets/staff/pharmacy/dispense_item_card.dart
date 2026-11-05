import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

import '../../../constants/common/common_text.dart';
import '../../../constants/staff/pharmacy_text.dart';
import '../../../utilities/staff/formatters.dart';

/// One prescribed medicine on the dispense screen: how to take it, what is still owed, and a − / + stepper for
/// how much to hand over now (0 … what is owed).
class DispenseItemCard extends StatelessWidget {
  const DispenseItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onChanged,
    this.checked = false,
  });

  final PrescriptionItem item;
  final double quantity;
  final ValueChanged<double> onChanged;

  /// Its pack was scanned and matched.
  final bool checked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final owed = item.outstanding;
    final unit = unitLabel(item.medication.unit, item.outstanding);
    final done = owed <= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(item.medication.name, style: theme.textTheme.titleMedium)),
                      if (checked) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: PharmacyText.packScannedAndMatched,
                          child: Icon(Icons.verified_rounded, size: 18, color: theme.colorScheme.primary),
                        ),
                      ],
                      if (item.medication.isControlled) ...[
                        const SizedBox(width: 6),
                        Tooltip(
                          message: PharmacyText.needsWitness,
                          child: Icon(Icons.lock_outline_rounded, size: 18, color: theme.colorScheme.error),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${item.dose} · ${item.frequency} · ${item.durationDays} days',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (item.instructions != null)
                    Text(item.instructions!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                  const SizedBox(height: 4),
                  Text(
                    done
                        ? PharmacyText.allHandedOver
                        : PharmacyText.owed(formatQuantity(owed), unit, formatQuantity(double.tryParse(item.quantity) ?? owed)),
                    style: theme.textTheme.labelMedium?.copyWith(color: done ? muted : theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            if (!done) ...[
              IconButton(
                tooltip: PharmacyText.less,
                onPressed: quantity <= 0 ? null : () => onChanged((quantity - 1).clamp(0, owed).toDouble()),
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  formatQuantity(quantity),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                ),
              ),
              IconButton(
                tooltip: CommonText.more,
                onPressed: quantity >= owed ? null : () => onChanged((quantity + 1).clamp(0, owed).toDouble()),
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
