import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/staff/leave_providers.dart';

/// `/hr/leaves/new` — type, days (a half day when it is one day), reason; goes to the manager, or waits as a
/// draft when the type needs a certificate. The server counts working days and checks the balance.
class NewLeaveScreen extends ConsumerStatefulWidget {
  const NewLeaveScreen({super.key});

  @override
  ConsumerState<NewLeaveScreen> createState() => _NewLeaveScreenState();
}

class _NewLeaveScreenState extends ConsumerState<NewLeaveScreen> {
  final _reason = TextEditingController();
  LeaveType? _type;
  DateTimeRange? _range;
  var _halfDay = false;

  bool get _oneDay => _range != null && DateUtils.isSameDay(_range!.start, _range!.end);

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickDays() async {
    final today = ClinicClock.parse(ClinicClock.today());
    final picked = await showDateRangePicker(
      context: context,
      // Sick leave is often asked for afterwards.
      firstDate: today.subtract(const Duration(days: 30)),
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _range,
      helpText: 'Days off',
    );
    if (picked != null) {
      setState(() {
        _range = picked;
        if (!_oneDay) _halfDay = false;
      });
    }
  }

  Future<void> _send() async {
    final type = _type;
    final range = _range;
    if (type == null || range == null) throw const ActionCancelled();
    final reason = _reason.text.trim();
    final leave = await ref
        .read(leaveRepositoryProvider)
        .request(
          leaveTypeId: type.id,
          startDate: ClinicClock.isoDate(range.start),
          endDate: ClinicClock.isoDate(range.end),
          isHalfDay: _halfDay,
          reason: reason.isEmpty ? null : reason,
        );
    ref.read(leavesVersionProvider.notifier).bump();
    if (!mounted) return;
    AppSnack.success(
      context,
      leave.isDraft ? 'Saved. Attach a photo of the certificate, then send it.' : 'Sent to your manager.',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final range = _range;
    final ready = _type != null && range != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Request leave')),
      body: AsyncBody(
        value: ref.watch(leaveTypesProvider),
        onRetry: () => ref.invalidate(leaveTypesProvider),
        data: (types) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SectionHeader('Kind of leave'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in types)
                    ChoiceChip(
                      label: Text(t.name),
                      selected: _type?.id == t.id,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
            ),
            if (_type case final type?) ...[
              if (type.requiresAttachment)
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InfoNote(
                    icon: Icons.attach_file_rounded,
                    text: 'Needs a certificate: the request is saved as a draft until you attach a photo of it.',
                  ),
                ),
              if (type.minNoticeDays > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: InfoNote(icon: Icons.schedule_rounded, text: 'Ask at least ${type.minNoticeDays} days ahead.'),
                ),
            ],
            const SectionHeader('Days'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _pickDays,
                icon: const Icon(Icons.date_range_rounded),
                label: Text(
                  range == null
                      ? 'Choose the days'
                      : _oneDay
                      ? ClinicClock.day(ClinicClock.isoDate(range.start))
                      : '${ClinicClock.date(ClinicClock.isoDate(range.start))} – ${ClinicClock.date(ClinicClock.isoDate(range.end))}',
                ),
              ),
            ),
            if (_oneDay)
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                value: _halfDay,
                onChanged: (v) => setState(() => _halfDay = v),
                title: const Text('Half day'),
              ),
            const SectionHeader('Reason (optional)'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _reason,
                maxLength: 1000,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(
        child: AppButton(
          label: ready ? (_type!.requiresAttachment ? 'Save draft' : 'Send request') : 'Choose the kind and the days',
          icon: Icons.send_rounded,
          lock: ButtonLock.once,
          expand: true,
          onPressed: ready ? _send : null,
        ),
      ),
    );
  }
}
