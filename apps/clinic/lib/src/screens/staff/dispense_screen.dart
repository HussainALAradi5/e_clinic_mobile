import 'dart:async';

import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/staff/pharmacy_providers.dart';
import '../../utilities/staff/dispense_plan.dart';
import '../../widgets/common/reason_field.dart';
import '../../widgets/staff/pharmacy/dispense_item_card.dart';
import '../../widgets/staff/pharmacy/pack_scan_sheet.dart';
import '../../widgets/staff/pharmacy/witness_picker.dart';

part 'dispense_screen_dispense_form.dart';
part 'dispense_screen_dispense_form_state.dart';

/// `/pharmacy/dispense/:id` — hand a prescription over: everything owed is preselected, lower what the patient
/// takes now, scan each pack to check it is the right medicine, a witness for controlled drugs, then *Dispense*. Batches are picked first-expiry-first-out by the
/// server, and the medicines go on the patient's invoice.
class DispenseScreen extends ConsumerWidget {
  const DispenseScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(prescriptionProvider(id));
    // The form keeps its quantities, so it is built once the prescription is in (with its own bar and button).
    if (value.value case final prescription?) return _DispenseForm(prescription: prescription);
    return Scaffold(
      appBar: AppBar(title: const Text('Dispense')),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(prescriptionProvider(id)),
        data: (_) => const SizedBox.shrink(),
      ),
    );
  }
}
