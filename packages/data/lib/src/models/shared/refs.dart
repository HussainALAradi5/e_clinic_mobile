import 'package:freezed_annotation/freezed_annotation.dart';

import 'money.dart';

part 'refs.freezed.dart';
part 'refs.g.dart';

part 'refs_employee_ref.dart';
part 'refs_named_ref.dart';
part 'refs_patient_ref.dart';
part 'refs_service_ref.dart';

/// `{ id, full_name }` — a doctor, performer or reporter shown by name.
@freezed
abstract class PersonRef with _$PersonRef {
  const factory PersonRef({required String id, required String fullName, String? jobTitle}) = _PersonRef;

  factory PersonRef.fromJson(Map<String, dynamic> json) => _$PersonRefFromJson(json);
}
