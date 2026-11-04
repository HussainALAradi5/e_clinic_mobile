import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// My latest visit fees (the server limits a patient to their own).
final myFeesProvider = FutureProvider.autoDispose<List<AppointmentFee>>(
  (ref) async =>
      (await ref.watch(appointmentFeeRepositoryProvider).list(const ListQuery(perPage: 20, sort: ['-createdAt'])))
          .items,
);
