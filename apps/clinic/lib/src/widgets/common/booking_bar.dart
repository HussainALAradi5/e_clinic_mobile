import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

/// The bottom bar of a booking screen: what is about to be booked, and the button (disabled until it is ready).
class BookingBar extends StatelessWidget {
  const BookingBar({super.key, required this.summary, required this.label, required this.onBook});

  /// "Mon 3 Nov at 09:30 with …" once everything is chosen.
  final String? summary;
  final String label;
  final Future<void> Function()? onBook;

  @override
  Widget build(BuildContext context) {
    return BottomBar(
      summary: summary,
      child: AppButton(
        label: label,
        icon: Icons.event_available_rounded,
        lock: ButtonLock.once,
        expand: true,
        onPressed: onBook,
      ),
    );
  }
}
