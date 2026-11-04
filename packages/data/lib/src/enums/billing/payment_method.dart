import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Shared\PaymentMethod — how money was paid.
@JsonEnum(fieldRename: FieldRename.snake)
enum PaymentMethod {
  cash,
  card,
  bankTransfer,
  benefitPay,
  insurance,
  cheque,
  patientBalance,

  /// A value this app version does not know yet.
  unknown;

  /// The ones offered as filters (not [unknown]).
  static const filters = [cash, card, bankTransfer, benefitPay, insurance, cheque];
}
