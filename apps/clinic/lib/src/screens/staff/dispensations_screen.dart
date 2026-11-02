import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/staff/pharmacy_providers.dart';
import '../../widgets/staff/pharmacy/dispensation_card.dart';

/// `/pharmacy/dispensing` — medicines that left the pharmacy, newest first; open one for its batches.
class DispensationsScreen extends ConsumerWidget {
  const DispensationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Dispensed medicines')),
    body: InfiniteList<Dispensation>(
      load: (page) => ref.read(dispensationRepositoryProvider).list(dispensationsQuery(page)),
      empty: const EmptyState(icon: Icons.inventory_2_outlined, title: 'Nothing dispensed yet'),
      itemBuilder: (context, dispensation, replace) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: DispensationCard(dispensation: dispensation, onChanged: replace),
      ),
    ),
  );
}
