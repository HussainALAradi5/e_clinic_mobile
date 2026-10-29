import 'package:json_annotation/json_annotation.dart';

/// Mirror of App\Enums\Appointments\AppointmentType.
@JsonEnum(fieldRename: FieldRename.snake)
enum AppointmentType { consultation, followUp, procedure, emergency, teleconsultation, treatmentSession, unknown }
