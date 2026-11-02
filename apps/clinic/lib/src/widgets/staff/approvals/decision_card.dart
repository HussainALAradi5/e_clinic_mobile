import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/staff/approval_actions.dart';

/// One request: what, who, the facts that matter, and the two decisions. Each button asks first (confirm or
/// reason) and locks only for the server call.
class DecisionCard extends ConsumerStatefulWidget {
  const DecisionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.facts,
    required this.decision,
  });

  final String title;
  final String subtitle;
  final List<Fact> facts;
  final Decision decision;

  @override
  ConsumerState<DecisionCard> createState() => _DecisionCardState();
}

class _DecisionCardState extends ConsumerState<DecisionCard> {
  String? _reason;

  Future<void> _approve() async {
    await widget.decision.approve(context);
    if (mounted) ApprovalActions.decided(context, ref, widget.decision.approved);
  }

  Future<void> _reject() async {
    await widget.decision.reject!(_reason!);
    if (mounted) ApprovalActions.decided(context, ref, 'Rejected.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decision = widget.decision;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: theme.textTheme.titleMedium),
                  Text(
                    widget.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            FactList(facts: widget.facts),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  if (decision.reject != null) ...[
                    Expanded(
                      child: AppButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        variant: ButtonVariant.outlined,
                        expand: true,
                        before: () async =>
                            (_reason = await ApprovalActions.askReason(context, decision.rejectTitle)) != null,
                        onPressed: _reject,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      icon: Icons.check_rounded,
                      expand: true,
                      confirm: decision.approveConfirm,
                      onPressed: _approve,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
