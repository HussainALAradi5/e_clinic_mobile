import 'package:e_clinic_core/core.dart';

import '../../enums/billing/payment_method.dart';
import '../../enums/billing/wallet_movement.dart';
import '../../models/billing/wallet_entry.dart';
import '../../models/shared/money.dart';

/// Patient balance — money the clinic holds for a patient. The server applies every limit and role rule.
class WalletRepository {
  const WalletRepository(this._api);

  final ApiClient _api;

  String _path(String patientId) => 'billing/patients/$patientId/wallet';

  /// Balance (list meta) plus the latest movements, newest first.
  Future<Wallet> get(String patientId, {int perPage = 20}) async {
    final page = await _api.list(
      _path(patientId),
      ListQuery(perPage: perPage, sort: const ['-createdAt']),
      WalletEntry.fromJson,
    );
    final balance = page.meta.extra['balance'];
    return (
      balance: balance is Map<String, dynamic> ? Money.fromJson(balance) : const Money(amount: '0.000'),
      entries: page.items,
    );
  }

  /// Deposit or pay-back ([method]) or adjustment ([credit]); a retried tap with the same [idempotencyKey] replays.
  Future<WalletEntry> move(
    String patientId,
    WalletMovement movement, {
    required String amount,
    PaymentMethod? method,
    bool credit = true,
    String? referenceNumber,
    String? reason,
    required String idempotencyKey,
  }) => _api.post(
    '${_path(patientId)}/${movement.path}',
    objectOf(WalletEntry.fromJson),
    body: {
      'amount': amount,
      if (movement == WalletMovement.adjust) 'direction': credit ? 'credit' : 'debit' else 'method': wireValue(method!),
      if (referenceNumber != null && referenceNumber.isNotEmpty) 'reference_number': referenceNumber,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    },
    idempotencyKey: idempotencyKey,
  );
}
