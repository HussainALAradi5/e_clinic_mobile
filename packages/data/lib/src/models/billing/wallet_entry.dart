import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';

part 'wallet_entry.freezed.dart';
part 'wallet_entry.g.dart';

/// Mirror of WalletEntryResource: one movement of a patient's balance, with the balance after it.
@freezed
abstract class WalletEntry with _$WalletEntry {
  const factory WalletEntry({
    required String id,
    required String code,

    /// WalletEntryType wire value (`deposit`, `invoice_payment` …).
    required String type,
    required bool isCredit,
    required Money amount,
    required Money balanceAfter,

    /// PaymentMethod wire value, for deposits and pay-backs.
    String? method,
    String? referenceNumber,
    String? invoiceId,
    String? reason,
    DateTime? createdAt,
  }) = _WalletEntry;

  factory WalletEntry.fromJson(Map<String, dynamic> json) => _$WalletEntryFromJson(json);
}

/// GET billing/patients/{id}/wallet: the current balance and the latest movements.
typedef Wallet = ({Money balance, List<WalletEntry> entries});
