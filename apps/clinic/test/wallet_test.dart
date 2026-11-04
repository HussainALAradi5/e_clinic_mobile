import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each balance movement posts to its own path with the methods the server allows', () {
    expect(WalletMovement.deposit.path, 'deposits');
    expect(WalletMovement.payback.path, 'withdrawals');
    expect(WalletMovement.adjust.path, 'adjustments');
    expect(WalletMovement.payback.methods, [PaymentMethod.cash, PaymentMethod.bankTransfer]);
    expect(WalletMovement.adjust.methods, isEmpty);
  });

  test('only deposits go without a reason', () {
    expect(WalletMovement.deposit.needsReason, isFalse);
    expect(WalletMovement.payback.needsReason, isTrue);
    expect(WalletMovement.adjust.needsReason, isTrue);
  });

  test('a balance movement reads its signed amount and the balance after it', () {
    final entry = WalletEntry.fromJson({
      'id': 'e-1',
      'code': 'WLT-000001',
      'type': 'deposit',
      'is_credit': true,
      'amount': {'amount': '25.000', 'currency': 'BHD'},
      'balance_after': {'amount': '25.000', 'currency': 'BHD'},
      'method': 'card',
    });
    expect(entry.isCredit, isTrue);
    expect(entry.balanceAfter.minor, 25000);
  });
}
