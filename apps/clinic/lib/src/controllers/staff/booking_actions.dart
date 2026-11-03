import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_providers.dart';
import 'staff_providers.dart';

/// The desk books a visit (desk bookings start confirmed).
abstract final class StaffBookingActions {
  /// Books the visit and refreshes the schedule. When the time went meanwhile, the provider's times are refreshed
  /// and [onTimeGone] runs (pick again with a new key).
  static Future<Appointment> book(
    WidgetRef ref, {
    required String patientId,
    required StaffSlotKey slotKey,
    required Slot slot,
    required AppointmentSource source,
    required String? reason,
    required String idempotencyKey,
    required VoidCallback onTimeGone,
  }) async {
    final Appointment booking;
    try {
      booking = await ref
          .read(appointmentRepositoryProvider)
          .book(
            patientId: patientId,
            providerId: slotKey.providerId,
            type: slotKey.type,
            date: slotKey.date,
            startTime: slot.startTime,
            source: source,
            reason: reason,
            idempotencyKey: idempotencyKey,
          );
    } on ApiException catch (error) {
      if (!error.isOffline) {
        ref.invalidate(staffSlotsProvider(slotKey));
        onTimeGone();
      }
      rethrow;
    }
    ref.read(scheduleVersionProvider.notifier).bump();
    return booking;
  }
}
