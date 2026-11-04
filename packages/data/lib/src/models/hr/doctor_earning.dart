import 'package:freezed_annotation/freezed_annotation.dart';
import '../shared/money.dart';

part 'doctor_earning.freezed.dart';
part 'doctor_earning.g.dart';

/// Mirror of one row of GET hr/doctor-earnings: a doctor's month — revenue, completed visits and commission.
@freezed
abstract class DoctorEarning with _$DoctorEarning {
  const factory DoctorEarning({
    /// CommissionType wire value (`none`, `percent`, `per_visit`).
    required String commissionType,
    required String rate,
    required Money revenue,
    required int visits,
    required Money commission,
  }) = _DoctorEarning;

  const DoctorEarning._();

  factory DoctorEarning.fromJson(Map<String, dynamic> json) => _$DoctorEarningFromJson(json);

  bool get onCommission => commissionType != 'none';
}
