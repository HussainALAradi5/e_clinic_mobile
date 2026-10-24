import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Appointments\ClinicalOrderType.
@JsonEnum(fieldRename: FieldRename.snake)
enum ClinicalOrderType {
  xray,
  ultrasound,
  ct,
  mri,
  labTest,
  ecg,
  referral,
  unknown;

  bool get isImaging => this == xray || this == ultrasound || this == ct || this == mri;
}
