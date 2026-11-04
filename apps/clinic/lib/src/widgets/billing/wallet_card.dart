import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/billing/wallet_text.dart';
import '../../controllers/billing/wallet_providers.dart';
import 'wallet_entry_row.dart';
import 'wallet_movement_sheet.dart';

/// A patient's balance with its latest movements. With [manage], staff get deposit / pay back / adjust buttons as
/// their role allows; the patient portal shows it read-only.
class WalletCard extends ConsumerWidget {
  const WalletCard({
    super.key,
    required this.patientId,
    this.manage = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String patientId;
  final bool manage;
  final EdgeInsets margin;

  Future<void> _move(BuildContext context, WidgetRef ref, WalletMovement movement, Money balance) async {
    final entry = await showModalBottomSheet<WalletEntry>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => WalletMovementSheet(patientId: patientId, movement: movement, balance: balance),
    );
    if (entry == null) return;
    ref.invalidate(walletProvider(patientId));
    if (context.mounted) AppSnack.success(context, WalletText.saved(entry.code, entry.balanceAfter.label));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final access = ref.watch(accessProvider);
    final actions = {
      WalletMovement.deposit: (access.can('wallet.deposit'), Icons.add_card_rounded, WalletText.deposit),
      WalletMovement.payback: (access.can('wallet.withdraw'), Icons.undo_rounded, WalletText.payback),
      WalletMovement.adjust: (access.can('wallet.adjust'), Icons.tune_rounded, WalletText.adjust),
    };
    return ref
        .watch(walletProvider(patientId))
        .when(
          loading: () => const SkeletonList(count: 1, height: 96),
          error: (error, _) => ErrorState(error: error, onRetry: () => ref.invalidate(walletProvider(patientId))),
          data: (wallet) => Card(
            margin: margin,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_rounded, color: scheme.primary),
                      const SizedBox(width: 10),
                      Text(WalletText.title, style: theme.textTheme.labelLarge),
                      const Spacer(),
                      Text(wallet.balance.label, style: theme.textTheme.headlineSmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manage ? WalletText.staffHint : WalletText.hint,
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  if (manage)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final MapEntry(key: movement, value: (allowed, icon, label)) in actions.entries)
                          if (allowed && (movement != WalletMovement.payback || wallet.balance.isPositive))
                            ActionChip(
                              avatar: Icon(icon, size: 18),
                              label: Text(label),
                              onPressed: () => _move(context, ref, movement, wallet.balance),
                            ),
                      ],
                    ),
                  const Divider(height: 20),
                  if (wallet.entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(WalletText.empty, style: theme.textTheme.bodySmall),
                    )
                  else
                    for (final entry in wallet.entries) WalletEntryRow(entry: entry),
                ],
              ),
            ),
          ),
        );
  }
}
