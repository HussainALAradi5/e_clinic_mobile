import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';

import '../../../constants/staff/appointment_text.dart';

class NoScheduleNotice extends StatelessWidget {
  const NoScheduleNotice({super.key});

  @override
  Widget build(BuildContext context) => const EmptyState(
    icon: Icons.work_outline_rounded,
    title: AppointmentText.noSchedule,
    message: AppointmentText.noScheduleHint,
  );
}
