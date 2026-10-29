import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Appointments\AppointmentSource — how a booking reached the clinic.
@JsonEnum(fieldRename: FieldRename.snake)
enum AppointmentSource { walkIn, phone, portal, referral }
