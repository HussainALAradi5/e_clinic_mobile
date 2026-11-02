import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/staff/visit_actions.dart';

/// The button of one visit step: asks first (no-show confirmation, follow-up for *Complete*), then locks for the
/// call only.
class VisitActionButton extends ConsumerStatefulWidget {
  const VisitActionButton({
    super.key,
    required this.action,
    required this.visit,
    this.variant = ButtonVariant.filled,
    this.expand = false,
  });

  final VisitAction action;
  final Appointment visit;
  final ButtonVariant variant;
  final bool expand;

  @override
  ConsumerState<VisitActionButton> createState() => _VisitActionButtonState();
}

class _VisitActionButtonState extends ConsumerState<VisitActionButton> {
  int? _followUp;

  Future<bool> _askFollowUp() async {
    final answer = await VisitActions.askFollowUp(context, widget.visit);
    _followUp = answer == 0 ? null : answer;
    return answer != null;
  }

  @override
  Widget build(BuildContext context) => AppButton(
    label: widget.action.label,
    icon: widget.action.icon,
    variant: widget.variant,
    expand: widget.expand,
    confirm: VisitActions.confirmFor(widget.action, widget.visit),
    before: widget.action == VisitAction.complete ? _askFollowUp : null,
    onPressed: () => VisitActions.run(context, ref, widget.action, widget.visit, followUpInDays: _followUp),
  );
}
