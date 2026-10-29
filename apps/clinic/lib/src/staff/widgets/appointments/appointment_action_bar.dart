import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_features/features.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/visit_actions.dart';
import '../visits/visit_action_button.dart';

class AppointmentActionBar extends ConsumerWidget {
  const AppointmentActionBar({super.key, required this.visit});

  final Appointment visit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = VisitAction.available(visit, ref.watch(accessProvider));
    if (actions.isEmpty) return const SizedBox.shrink();
    final primary = VisitAction.primary(actions);
    final others = actions.where((a) => a != primary).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            for (final action in others) ...[
              VisitActionButton(action: action, visit: visit, variant: ButtonVariant.outlined),
              const SizedBox(width: 8),
            ],
            if (primary != null)
              Expanded(
                child: VisitActionButton(action: primary, visit: visit, expand: true),
              ),
          ],
        ),
      ),
    );
  }
}
