import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utilities/staff/formatters.dart';
import 'request_tone.dart';

/// Ask HR about one of my days: the day as attendance measured it, an optional reason, *Send to HR*. Returns the new
/// request, or null when backed out.
Future<StaffRequest?> showAskRequestSheet(BuildContext context, {required Attendance day, required String type}) =>
    showModalBottomSheet<StaffRequest>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AskRequestSheet(day: day, type: type),
    );

class _AskRequestSheet extends ConsumerStatefulWidget {
  const _AskRequestSheet({required this.day, required this.type});

  final Attendance day;
  final String type;

  @override
  ConsumerState<_AskRequestSheet> createState() => _AskRequestSheetState();
}

class _AskRequestSheetState extends ConsumerState<_AskRequestSheet> {
  final _reason = TextEditingController();

  bool get _late => widget.type == StaffRequestTypes.lateExcuse;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final reason = _reason.text.trim();
    final created = await ref
        .read(staffRequestRepositoryProvider)
        .create(type: widget.type, attendanceId: widget.day.id, reason: reason.isEmpty ? null : reason);
    if (mounted) Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tone = RequestTone.of(context, late: _late);
    final day = widget.day;
    final minutes = _late ? day.lateMinutes : day.overtimeMinutes;
    final times = 'In ${clockTime(day.checkInAt)} · Out ${clockTime(day.checkOutAt)}';
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_late ? 'Excuse my late arrival' : 'Pay my overtime', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: RequestTone.soft(context, late: _late),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(RequestTone.icon(late: _late), color: tone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ClinicClock.date(day.date), style: theme.textTheme.titleSmall),
                        Text(times, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Text(
                    formatMinutes(minutes),
                    style: theme.textTheme.titleMedium?.copyWith(color: tone, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _late
                  ? 'Late minutes are deducted from your pay unless HR accepts your excuse.'
                  : "Overtime is paid once HR approves it, at the clinic's overtime rate per hour.",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reason,
              maxLength: 1000,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Reason (optional)',
                hintText: _late ? 'e.g. traffic, a sick child' : 'e.g. an emergency patient, covering a colleague',
              ),
            ),
            const SizedBox(height: 12),
            AppButton(label: 'Send to HR', icon: Icons.send_rounded, expand: true, onPressed: _send),
            const SizedBox(height: 4),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Not now')),
          ],
        ),
      ),
    );
  }
}
