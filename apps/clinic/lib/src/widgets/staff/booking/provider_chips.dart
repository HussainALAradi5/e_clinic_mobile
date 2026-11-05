import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/staff/booking_text.dart';
import '../../../controllers/staff/calendar_providers.dart';

/// Who takes this kind of visit, as chips (job title and department in the tooltip).
class ProviderChips extends ConsumerWidget {
  const ProviderChips({super.key, required this.type, required this.selectedId, required this.onSelected});

  final AppointmentType type;
  final String? selectedId;
  final ValueChanged<BookingProvider> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(bookingProvidersProvider(type))
        .when(
          loading: () => const SkeletonList(count: 2, height: 56),
          error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(bookingProvidersProvider(type))),
          data: (providers) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: providers.isEmpty
                ? const InfoNote(icon: Icons.person_off_outlined, text: BookingText.noProvider)
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in providers)
                        ChoiceChip(
                          avatar: CircleAvatar(child: Text(initials(p.fullName))),
                          label: Text(p.fullName),
                          tooltip: [p.jobTitle, p.department].whereType<String>().join(' · '),
                          selected: selectedId == p.id,
                          onSelected: (_) => onSelected(p),
                        ),
                    ],
                  ),
          ),
        );
  }
}
