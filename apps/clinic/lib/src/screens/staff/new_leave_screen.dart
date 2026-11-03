import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/staff/leave_providers.dart';
import '../../widgets/common/reason_field.dart';
import '../../widgets/staff/leaves/leave_days_field.dart';
import '../../widgets/staff/leaves/leave_type_picker.dart';

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

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
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
    final ready = _type != null && _range != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Request leave')),
      body: AsyncBody(
        value: ref.watch(leaveTypesProvider),
        onRetry: () => ref.invalidate(leaveTypesProvider),
        data: (types) => ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SectionHeader('Kind of leave'),
            LeaveTypePicker(types: types, selected: _type, onSelected: (t) => setState(() => _type = t)),
            const SectionHeader('Days'),
            LeaveDaysField(
              range: _range,
              halfDay: _halfDay,
              onRange: (range) => setState(() {
                _range = range;
                if (!LeaveDaysField.isOneDay(range)) _halfDay = false;
              }),
              onHalfDay: (v) => setState(() => _halfDay = v),
            ),
            const SectionHeader('Reason (optional)'),
            ReasonField(controller: _reason, maxLength: 1000, minLines: 2, maxLines: 4),
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
