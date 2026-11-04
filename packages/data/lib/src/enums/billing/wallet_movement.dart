import 'payment_method.dart';

/// What staff do to a patient's balance; [path] is its endpoint under `patients/{id}/wallet`.
enum WalletMovement {
  deposit('deposits', [PaymentMethod.cash, PaymentMethod.card, PaymentMethod.benefitPay, PaymentMethod.bankTransfer]),
  payback('withdrawals', [PaymentMethod.cash, PaymentMethod.bankTransfer]),
  adjust('adjustments', []);

  const WalletMovement(this.path, this.methods);

  final String path;

  /// Methods the server accepts for this movement (config payments.wallet); none for adjustments.
  final List<PaymentMethod> methods;

  /// Pay-backs and adjustments need a written reason.
  bool get needsReason => this != deposit;

  /// Shortest reason the server accepts.
  static const reasonMinLength = 10;
}
