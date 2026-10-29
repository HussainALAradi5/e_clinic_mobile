import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/pharmacy_providers.dart';
import '../utils/dispense_plan.dart';
import '../widgets/pharmacy/dispense_item_card.dart';

/// `/pharmacy/dispense/:id` — hand a prescription over: everything owed is preselected, lower what the patient
/// takes now, a witness for controlled drugs, then *Dispense*. Batches are picked first-expiry-first-out by the
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

class _DispenseForm extends ConsumerStatefulWidget {
  const _DispenseForm({required this.prescription});

  final Prescription prescription;

  @override
  ConsumerState<_DispenseForm> createState() => _DispenseFormState();
}

class _DispenseFormState extends ConsumerState<_DispenseForm> {
  late final DispenseQuantities _quantities = owedQuantities(widget.prescription);
  final _notes = TextEditingController();
  final _idempotencyKey = ApiClient.newIdempotencyKey();
  String? _witnessId;

  Prescription get _p => widget.prescription;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _dispense() async {
    final lines = dispenseLines(_p, _quantities);
    if (lines.isEmpty) throw const ActionCancelled();
    final notes = _notes.text.trim();
    await ref
        .read(dispensationRepositoryProvider)
        .dispense(
          patientId: _p.patient!.id,
          prescriptionId: _p.id,
          items: lines,
          witnessId: needsWitness(_p, _quantities) ? _witnessId : null,
          notes: notes.isEmpty ? null : notes,
          idempotencyKey: _idempotencyKey,
        );
    ref.read(pharmacyVersionProvider.notifier).bump();
    if (!mounted) return;
    AppSnack.success(context, 'Handed over and charged to ${_p.patient!.fullName}.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final lines = dispenseLines(_p, _quantities);
    final witness = needsWitness(_p, _quantities);
    final ready = _p.patient != null && lines.isNotEmpty && (!witness || _witnessId != null);
    return Scaffold(
      appBar: AppBar(title: Text(_p.code)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ProfileHeader(
              name: _p.patient?.fullName ?? 'Patient',
              lines: [
                _p.patient?.code,
                [
                  if (_p.doctor != null) 'Dr ${_p.doctor!.fullName}',
                  'valid until ${ClinicClock.date(_p.validUntil)}',
                ].join(' · '),
              ],
            ),
          ),
          if (_p.notes != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: InfoNote(icon: Icons.sticky_note_2_outlined, text: _p.notes!),
            ),
          const SectionHeader('Medicines'),
          for (final item in _p.items)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: DispenseItemCard(
                item: item,
                quantity: _quantities[item.id] ?? 0,
                onChanged: (q) => setState(() => _quantities[item.id] = q),
              ),
            ),
          if (witness) ...[
            const SectionHeader('Witness'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ref
                  .watch(witnessesProvider)
                  .when(
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(witnessesProvider)),
                    data: (people) => DropdownButtonFormField<String>(
                      initialValue: _witnessId,
                      decoration: const InputDecoration(
                        labelText: 'Colleague who checks the controlled drug',
                        prefixIcon: Icon(Icons.verified_user_outlined),
                      ),
                      items: [for (final p in people) DropdownMenuItem(value: p.id, child: Text(p.fullName))],
                      onChanged: (id) => setState(() => _witnessId = id),
                    ),
                  ),
            ),
          ],
          const SectionHeader('Notes (optional)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _notes,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'e.g. patient will collect the rest next week'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(
        summary: lines.isEmpty
            ? null
            : '${lines.length} medicine${lines.length == 1 ? '' : 's'} for ${_p.patient?.fullName ?? 'the patient'}',
        child: AppButton(
          label: switch ((lines.isEmpty, witness && _witnessId == null)) {
            (true, _) => 'Nothing to hand over',
            (_, true) => 'Choose a witness',
            _ => 'Dispense',
          },
          icon: Icons.medication_rounded,
          lock: ButtonLock.once,
          expand: true,
          confirm: ConfirmConfig(
            title: 'Hand over ${lines.length} medicine${lines.length == 1 ? '' : 's'}?',
            message: 'Stock goes down and the medicines are added to the invoice.',
            confirmLabel: 'Dispense',
          ),
          onPressed: ready ? _dispense : null,
        ),
      ),
    );
  }
}
