import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';

part 'patient_package.freezed.dart';
part 'patient_package.g.dart';

/// Mirror of PatientPackageResource: a package I bought — sessions used and left, and until when it is valid.
@freezed
abstract class PatientPackage with _$PatientPackage {
  const factory PatientPackage({
    required String id,
    required String code,
    required String name,

    /// PatientPackageStatus wire value (`awaiting_payment`, `active`, `used_up`, `expired`, `cancelled`).
    required String status,
    required int sessionsTotal,
    required int sessionsUsed,
    required int sessionsLeft,
    required Money price,
    String? expiresOn,
  }) = _PatientPackage;

  const PatientPackage._();

  factory PatientPackage.fromJson(Map<String, dynamic> json) => _$PatientPackageFromJson(json);

  bool get active => status == 'active';

  /// Share of the sessions used, 0–1.
  double get usedShare => sessionsTotal == 0 ? 0 : sessionsUsed / sessionsTotal;
}
