import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Payments\InvoiceStatus (drafts never reach the patient).
@JsonEnum(fieldRename: FieldRename.snake)
enum InvoiceStatus {
  draft,
  issued,
  partiallyPaid,
  paid,
  cancelled,
  unknown;

  static const owing = [issued, partiallyPaid];
}
