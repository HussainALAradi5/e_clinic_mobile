import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/staff/staff_providers.dart';
import '../../widgets/staff/appointments/appointment_action_bar.dart';
import '../../widgets/staff/appointments/appointment_details.dart';

/// `/clinic/appointments/:id` — one booking: who, when, where, its status, and every step this user may take
/// (the main one as the bottom button).
class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(appointmentProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text(booking.value?.code ?? 'Booking')),
      body: AsyncBody(
        value: booking,
        onRetry: () => ref.invalidate(appointmentProvider(id)),
        data: (visit) => AppointmentDetails(visit: visit),
      ),
      bottomNavigationBar: booking.hasValue ? AppointmentActionBar(visit: booking.value!) : null,
    );
  }
}
