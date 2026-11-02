part of 'invoice.dart';

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    required String code,
    required Money amount,
    required String method,
    required String status,
    String? cardLast4,
    required DateTime paidAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
