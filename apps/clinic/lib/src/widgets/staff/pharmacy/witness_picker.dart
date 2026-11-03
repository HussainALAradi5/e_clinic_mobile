import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/staff/pharmacy_providers.dart';

/// The colleague who checks a controlled drug being handed over.
class WitnessPicker extends ConsumerWidget {
  const WitnessPicker({super.key, required this.selectedId, required this.onChanged});

  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ref
          .watch(witnessesProvider)
          .when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(witnessesProvider)),
            data: (people) => DropdownButtonFormField<String>(
              initialValue: selectedId,
              decoration: const InputDecoration(
                labelText: 'Colleague who checks the controlled drug',
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
              items: [for (final p in people) DropdownMenuItem(value: p.id, child: Text(p.fullName))],
              onChanged: onChanged,
            ),
          ),
    );
  }
}
