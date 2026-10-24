import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/approval_actions.dart';
import '../application/staff_providers.dart';

/// `/approvals` — everything waiting for this user's decision: refunds, expenses, leave and overtime (each section
/// only with the matching right). Approve asks to confirm; reject asks for a reason the requester sees.
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Scaffold(
      appBar: AppBar(title: const Text('Approvals')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(approvalsProvider);
          await ref.read(approvalsProvider.future);
        },
        child: ref
            .watch(approvalsProvider)
            .when(
              loading: () => ListView(children: const [SizedBox(height: 16), SkeletonList()]),
              error: (error, _) => ListView(
                children: [ErrorState(error: error, onRetry: () => ref.invalidate(approvalsProvider))],
              ),
              data: (a) {
                final empty = a.refunds.isEmpty && a.expenses.isEmpty && a.leaves.isEmpty && a.overtime.isEmpty;
                if (empty) {
                  return ListView(
                    children: const [
                      EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: 'All caught up',
                        message: 'Nothing is waiting for your decision. Pull down to check again.',
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    if (a.refunds.isNotEmpty) ...[
                      SectionHeader('Refunds · ${a.refunds.length}'),
                      for (final r in a.refunds)
                        _DecisionCard(
                          title: '${r.amount.label} · ${catalog.label('PaymentMethod', r.method)}',
                          subtitle: r.patient?.fullName ?? r.code,
                          facts: [
                            (label: 'Reason', value: r.reason),
                            (label: 'Asked by', value: r.requestedBy?.fullName),
                            (label: 'Asked', value: r.createdAt == null ? null : ClinicClock.ago(r.createdAt!)),
                          ],
                          decision: ApprovalActions.refund(ref, r),
                        ),
                    ],
                    if (a.expenses.isNotEmpty) ...[
                      SectionHeader('Expenses · ${a.expenses.length}'),
                      for (final e in a.expenses)
                        _DecisionCard(
                          title: '${e.amount.label} · ${catalog.label('ExpenseCategory', e.category)}',
                          subtitle: e.payeeName ?? e.code,
                          facts: [
                            (label: 'What for', value: e.description),
                            (label: 'Date', value: ClinicClock.date(e.expenseDate)),
                          ],
                          decision: ApprovalActions.expense(ref, e),
                        ),
                    ],
                    if (a.leaves.isNotEmpty) ...[
                      SectionHeader('Leave · ${a.leaves.length}'),
                      for (final l in a.leaves)
                        _DecisionCard(
                          title: l.employee?.fullName ?? l.code,
                          subtitle: '${l.leaveType?.name ?? 'Leave'} · ${ApprovalActions.leaveDays(l)}',
                          facts: [
                            (label: 'Role', value: l.employee?.jobTitle),
                            (label: 'Reason', value: l.reason),
                            (
                              label: 'Documents',
                              value: (l.attachmentsCount ?? 0) > 0 ? '${l.attachmentsCount} attached' : null,
                            ),
                          ],
                          decision: ApprovalActions.leave(ref, l),
                        ),
                    ],
                    if (a.overtime.isNotEmpty) ...[
                      SectionHeader('Overtime · ${a.overtime.length}'),
                      for (final o in a.overtime)
                        _DecisionCard(
                          title: o.employee?.fullName ?? 'Staff member',
                          subtitle: '${ApprovalActions.minutesLabel(o.overtimeMinutes)} on ${ClinicClock.date(o.date)}',
                          facts: [
                            (label: 'Role', value: o.employee?.jobTitle),
                            (
                              label: 'Checked out',
                              value: o.checkOutAt == null ? null : ClinicClock.dateTime(o.checkOutAt!),
                            ),
                          ],
                          decision: ApprovalActions.overtime(ref, o),
                        ),
                    ],
                  ],
                );
              },
            ),
      ),
    );
  }
}

/// One request: what, who, the facts that matter, and the two decisions. Each button asks first (confirm or
/// reason) and locks only for the server call.
class _DecisionCard extends ConsumerStatefulWidget {
  const _DecisionCard({required this.title, required this.subtitle, required this.facts, required this.decision});

  final String title;
  final String subtitle;
  final List<Fact> facts;
  final Decision decision;

  @override
  ConsumerState<_DecisionCard> createState() => _DecisionCardState();
}

class _DecisionCardState extends ConsumerState<_DecisionCard> {
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
