import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// My commission this month as a doctor; null when I am not on commission (or not a doctor).
final myEarningProvider = FutureProvider.autoDispose<DoctorEarning?>((ref) async {
  final today = ClinicClock.parse(ClinicClock.today());
  final row = await ref.watch(earningRepositoryProvider).mine(today.year, today.month);
  return row != null && row.onCommission ? row : null;
});
