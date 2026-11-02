import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/material.dart';

class DoctorTile extends StatelessWidget {
  const DoctorTile({super.key, required this.doctor, required this.price, required this.selected, required this.onTap});

  final Doctor doctor;
  final Money? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: selected ? scheme.primary : scheme.secondaryContainer,
                foregroundColor: selected ? scheme.onPrimary : scheme.onSecondaryContainer,
                child: Text(initials(doctor.fullName)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor.displayName, style: theme.textTheme.titleSmall),
                    if (doctor.specialty != null)
                      Text(
                        doctor.specialty!.name,
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              if (price != null) Text(price!.label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
