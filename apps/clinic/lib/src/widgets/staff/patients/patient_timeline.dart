import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/staff_paths.dart';
import '../../../constants/staff/patient_text.dart';

/// The patient's history, newest first (the latest few, then *Show all*): visits open the booking, orders the
/// order when the user may open orders.
class PatientTimeline extends StatefulWidget {
  const PatientTimeline({super.key, required this.entries, required this.canOpenOrders});

  final List<PatientTimelineEntry> entries;
  final bool canOpenOrders;

  @override
  State<PatientTimeline> createState() => _PatientTimelineState();
}

class _PatientTimelineState extends State<PatientTimeline> {
  static const _shown = 8;
  var _all = false;

  static IconData _icon(String kind) => switch (kind) {
    'appointment' => Icons.event_note_rounded,
    'treatment' => Icons.healing_rounded,
    'order' => Icons.biotech_rounded,
    _ => Icons.circle_outlined,
  };

  String? _link(PatientTimelineEntry entry) => switch (entry.kind) {
    'appointment' => StaffPaths.appointment(entry.id),
    'order' when widget.canOpenOrders => StaffPaths.order(entry.id),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: InfoNote(icon: Icons.history_rounded, text: PatientText.emptyFile),
      );
    }
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final entry in _all ? entries : entries.take(_shown))
            ListTile(
              leading: Icon(_icon(entry.kind), color: muted),
              title: Text(entry.title),
              subtitle: Text(ClinicClock.dateTime(entry.at)),
              trailing: entry.status == null
                  ? null
                  : StatusChip(
                      enumName: entry.kind == 'appointment' ? 'AppointmentStatus' : 'GenericStatus',
                      value: entry.status!,
                    ),
              onTap: switch (_link(entry)) {
                final path? => () => context.push(path),
                null => null,
              },
            ),
          if (!_all && entries.length > _shown)
            TextButton(onPressed: () => setState(() => _all = true), child: Text(PatientText.showAll(entries.length))),
        ],
      ),
    );
  }
}
