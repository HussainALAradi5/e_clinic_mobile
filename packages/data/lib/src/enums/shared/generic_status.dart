import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Shared\Enums\GenericStatus — treatments, orders, prescriptions.
@JsonEnum(fieldRename: FieldRename.snake)
enum GenericStatus {
  pending,
  inProgress,
  completed,
  cancelled,
  unknown;

  static const open = [pending, inProgress];
}
