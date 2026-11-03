import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'booking_providers.dart';
import 'portal_providers.dart';

/// The patient books a visit online.
abstract final class PortalBookingActions {
  /// Sends the booking (pending until the clinic confirms it) and refreshes My visits. When someone else took the
  /// time meanwhile, the doctor's times are refreshed and [onTimeGone] runs (pick again with a new key).
  static Future<void> book(
    WidgetRef ref, {
    required SlotKey slotKey,
    required Slot slot,
    required String? reason,
    required String idempotencyKey,
    required VoidCallback onTimeGone,
  }) async {
    try {
      await ref
          .read(portalRepositoryProvider)
          .book(
            doctorId: slotKey.doctorId,
            type: slotKey.type,
            date: slotKey.date,
            startTime: slot.startTime,
            reason: reason,
            idempotencyKey: idempotencyKey,
          );
    } on ApiException catch (error) {
      if (!error.isOffline) {
        ref.invalidate(slotsProvider(slotKey));
        onTimeGone();
      }
      rethrow;
    }
    ref.read(visitsVersionProvider.notifier).bump();
  }
}
