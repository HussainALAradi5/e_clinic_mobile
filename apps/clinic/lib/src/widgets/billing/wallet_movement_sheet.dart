import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/billing/wallet_text.dart';

/// Deposit, pay-back or adjustment of a patient's balance; pops with the saved entry. The form mirrors the server's
/// rules (reason for pay-backs and adjustments, bank reference for transfers); the server applies limits and roles.
class WalletMovementSheet extends ConsumerStatefulWidget {
  const WalletMovementSheet({super.key, required this.patientId, required this.movement, required this.balance});

  final String patientId;
  final WalletMovement movement;
  final Money balance;

  @override
  ConsumerState<WalletMovementSheet> createState() => _WalletMovementSheetState();
}

class _WalletMovementSheetState extends ConsumerState<WalletMovementSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  final _reason = TextEditingController();
  final _key = ApiClient.newIdempotencyKey();
  late PaymentMethod? _method = widget.movement.methods.firstOrNull;
  bool _credit = true;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) throw const ActionCancelled();
    final entry = await ref
        .read(walletRepositoryProvider)
        .move(
          widget.patientId,
          widget.movement,
          amount: _amount.text.trim(),
          method: _method,
          credit: _credit,
          referenceNumber: _reference.text.trim(),
          reason: _reason.text.trim(),
          idempotencyKey: _key,
        );
    if (mounted) Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final movement = widget.movement;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(WalletText.titles[movement]!, style: theme.textTheme.titleLarge),
              Text(WalletText.available(widget.balance.label), style: theme.textTheme.bodySmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: WalletText.amount),
                validator: (v) => (MoneyFormat.toMinor(v) ?? 0) > 0 ? null : WalletText.amountInvalid,
              ),
              const SizedBox(height: 12),
              if (movement == WalletMovement.adjust)
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text(WalletText.credit), icon: Icon(Icons.add_rounded)),
                    ButtonSegment(value: false, label: Text(WalletText.debit), icon: Icon(Icons.remove_rounded)),
                  ],
                  selected: {_credit},
                  onSelectionChanged: (s) => setState(() => _credit = s.first),
                )
              else
                Wrap(
                  spacing: 8,
                  children: [
                    for (final m in movement.methods)
                      ChoiceChip(
                        label: Text(WalletText.methods[m] ?? m.name),
                        selected: _method == m,
                        onSelected: (_) => setState(() => _method = m),
                      ),
                  ],
                ),
              if (_method == PaymentMethod.bankTransfer && movement != WalletMovement.adjust) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reference,
                  decoration: const InputDecoration(labelText: WalletText.reference),
                  validator: (v) => (v ?? '').trim().isEmpty ? WalletText.referenceRequired : null,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _reason,
                maxLines: 2,
                maxLength: 500,
                decoration: InputDecoration(labelText: movement.needsReason ? WalletText.reason : WalletText.notes),
                validator: (v) => movement.needsReason && (v ?? '').trim().length < WalletMovement.reasonMinLength
                    ? WalletText.reasonShort(WalletMovement.reasonMinLength)
                    : null,
              ),
              const SizedBox(height: 12),
              AppButton(label: WalletText.titles[movement]!, onPressed: _save, expand: true),
            ],
          ),
        ),
      ),
    );
  }
}
