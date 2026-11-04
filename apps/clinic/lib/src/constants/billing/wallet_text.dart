import 'package:e_clinic_data/data.dart';

/// Text of the patient balance card and the movement sheet.
abstract final class WalletText {
  static const title = 'Balance';
  static const hint = 'Money the clinic holds for you. It can pay your invoices at the desk.';
  static const staffHint = 'Money the clinic holds for the patient. It can pay their invoices.';
  static const empty = 'No movements yet.';
  static const deposit = 'Deposit';
  static const payback = 'Pay back';
  static const adjust = 'Adjust';
  static const amount = 'Amount (BHD)';
  static const method = 'Paid by';
  static const reference = 'Bank reference';
  static const reason = 'Reason';
  static const notes = 'Notes';
  static const credit = 'Add';
  static const debit = 'Take';
  static const amountInvalid = 'Enter an amount above zero with up to 3 decimals.';
  static const referenceRequired = 'A bank transfer needs its reference.';
  static String reasonShort(int min) => 'Write at least $min characters.';
  static String saved(String code, String balance) => '$code saved — balance is now $balance.';
  static String available(String balance) => 'Available $balance';

  static const titles = {
    WalletMovement.deposit: 'Deposit to balance',
    WalletMovement.payback: 'Pay back from balance',
    WalletMovement.adjust: 'Adjust balance',
  };

  static const methods = {
    PaymentMethod.cash: 'Cash',
    PaymentMethod.card: 'Card',
    PaymentMethod.benefitPay: 'BenefitPay',
    PaymentMethod.bankTransfer: 'Bank transfer',
  };
}
