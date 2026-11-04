import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// My packages, newest first.
final myPackagesProvider = FutureProvider.autoDispose<List<PatientPackage>>(
  (ref) async =>
      (await ref.watch(packageRepositoryProvider).mine(const ListQuery(perPage: 20, sort: ['-createdAt']))).items,
);
