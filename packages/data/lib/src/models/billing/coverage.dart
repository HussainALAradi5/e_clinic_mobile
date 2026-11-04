import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';

part 'coverage.freezed.dart';
part 'coverage.g.dart';

/// Mirror of CoverageResource: how an invoice splits between the insurer and the patient.
@freezed
abstract class Coverage with _$Coverage {
  const factory Coverage({
    required bool covered,

    /// Why the patient pays it all: no_insurance, expired, nothing_insurable, claim_rejected.
    String? reason,
    String? insurer,
    required String coveragePercent,
    required Money insurerShare,
    required Money patientShare,
    required Money patientDue,
  }) = _Coverage;

  factory Coverage.fromJson(Map<String, dynamic> json) => _$CoverageFromJson(json);
}
