import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

class NoScheduleNotice extends StatelessWidget {
  const NoScheduleNotice({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.work_outline_rounded,
    title: 'Your work is on the other tabs',
    message: 'Your role has no patient bookings. Use the tabs below for the rest of your work.',
  );
}
