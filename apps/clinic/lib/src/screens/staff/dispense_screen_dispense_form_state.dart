part of 'dispense_screen.dart';

class _DispenseFormState extends ConsumerState<_DispenseForm> {
  late final DispenseQuantities _quantities = owedQuantities(widget.prescription);

  /// Lines whose pack was scanned and matched (a check that the right medicine is in hand).
  final _checked = <String>{};
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

  Future<void> _scan() async {
    final code = await scanPack(context);
    if (code == null || !mounted) return;
    final item = itemForBarcode(_p, code);
    if (item == null) {
      unawaited(HapticFeedback.heavyImpact());
      AppSnack.error(
        context,
        ApiException(status: 0, code: ErrorCodes.unexpected, message: 'This pack ($code) is not on the prescription.'),
      );
      return;
    }
    setState(() => _checked.add(item.id));
    AppSnack.success(context, '${item.medication.name} matches.');
  }

  @override
  Widget build(BuildContext context) {
    final lines = dispenseLines(_p, _quantities);
    final witness = needsWitness(_p, _quantities);
    final ready = _p.patient != null && lines.isNotEmpty && (!witness || _witnessId != null);
    return Scaffold(
      appBar: AppBar(
        title: Text(_p.code),
        actions: [
          IconButton(tooltip: 'Scan a pack', icon: const Icon(Icons.qr_code_scanner_rounded), onPressed: _scan),
        ],
      ),
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
                checked: _checked.contains(item.id),
                onChanged: (q) => setState(() => _quantities[item.id] = q),
              ),
            ),
          if (witness) ...[
            const SectionHeader('Witness'),
            WitnessPicker(selectedId: _witnessId, onChanged: (id) => setState(() => _witnessId = id)),
          ],
          const SectionHeader('Notes (optional)'),
          ReasonField(controller: _notes, hint: 'e.g. patient will collect the rest next week', maxLines: 1),
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
