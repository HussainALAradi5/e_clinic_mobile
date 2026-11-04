import 'package:e_clinic_data/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A patient's balance and latest movements (staff: any patient they may see; patient: their own id).
final walletProvider = FutureProvider.autoDispose.family<Wallet, String>(
  (ref, patientId) => ref.watch(walletRepositoryProvider).get(patientId, perPage: 10),
);
