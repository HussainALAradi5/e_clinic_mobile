import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/portal_actions.dart';
import 'ticket_pill.dart';

/// The next visit as a pine ticket: when, with whom, the check-in code.
class NextVisitTicket extends ConsumerWidget {
  const NextVisitTicket({super.key, required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    const onPine = Colors.white;
    const soft = Color(0xFFC6F0E8);
    final parts = ClinicClock.parts(visit.scheduledDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? BrandColors.pineDeep : BrandColors.pine,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Your next visit', style: theme.textTheme.labelLarge?.copyWith(color: soft)),
                const Spacer(),
                if (visit.status == AppointmentStatus.pending)
                  const TicketPill(text: 'Awaiting confirmation', color: BrandColors.sun, textColor: Color(0xFF3D2A00))
                else
                  const TicketPill(text: 'Confirmed', color: Color(0x33FFFFFF), textColor: onPine),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${parts.day}',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: onPine,
                    fontWeight: FontWeight.w700,
                    height: 0.9,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${parts.weekday} · ${parts.month}',
                        style: theme.textTheme.titleMedium?.copyWith(color: onPine),
                      ),
                      Text(
                        visit.startTime,
                        style: theme.textTheme.titleLarge?.copyWith(color: onPine, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.medical_services_outlined, color: soft, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(visit.doctorName, style: theme.textTheme.bodyLarge?.copyWith(color: onPine)),
                ),
              ],
            ),
            if (visit.room != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.meeting_room_outlined, color: soft, size: 18),
                  const SizedBox(width: 8),
                  Text(visit.room!.name, style: theme.textTheme.bodyMedium?.copyWith(color: soft)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: BrandColors.pine),
                    onPressed: () => PortalActions.showVisitCode(context, visit),
                    icon: const Icon(Icons.qr_code_2_rounded),
                    label: const Text('Check-in code'),
                  ),
                ),
                if (visit.status.cancellable) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: soft),
                    onPressed: () => PortalActions.cancelVisit(context, ref, visit),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
