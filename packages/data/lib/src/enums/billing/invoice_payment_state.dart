import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Payments\InvoicePaymentState — how an invoice stands with its payments (worked out by
/// the server: unpaid after its due date is overdue, any refund on a paid invoice is refunded).
@JsonEnum(fieldRename: FieldRename.snake)
enum InvoicePaymentState {
  draft,
  unpaid,
  overdue,
  partiallyPaid,
  paid,
  refunded,
  cancelled,

  /// A value this app version does not know yet.
  unknown;

  /// The ones a patient filters by.
  static const patientFilters = [unpaid, overdue, partiallyPaid, paid, refunded];
}
