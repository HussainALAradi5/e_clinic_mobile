import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/common/common_text.dart';
import '../../constants/staff/approval_text.dart';
import '../../controllers/staff/approval_actions.dart';
import '../../controllers/staff/staff_providers.dart';
import '../../utilities/staff/formatters.dart';
import '../../widgets/staff/approvals/decision_card.dart';

/// `/approvals` — everything waiting for this user's decision: refunds, expenses, leave, late excuse and overtime
/// requests, and overtime (each section
/// only with the matching right). Approve asks to confirm; reject asks for a reason the requester sees.
class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(enumCatalogProvider).value ?? EnumCatalog.empty;
    return Scaffold(
      appBar: AppBar(title: const Text(ApprovalText.approvals)),
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
                final empty =
                    a.refunds.isEmpty &&
                    a.expenses.isEmpty &&
                    a.leaves.isEmpty &&
                    a.overtime.isEmpty &&
                    a.requests.isEmpty;
                if (empty) {
                  return ListView(
                    children: const [
                      EmptyState(
                        icon: Icons.task_alt_rounded,
                        title: ApprovalText.allCaughtUp,
                        message: ApprovalText.allCaughtUpHint,
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
                        DecisionCard(
                          title: '${r.amount.label} · ${catalog.label('PaymentMethod', r.method)}',
                          subtitle: r.patient?.fullName ?? r.code,
                          facts: [
                            (label: CommonText.reason, value: r.reason),
                            (label: ApprovalText.askedBy, value: r.requestedBy?.fullName),
                            (label: ApprovalText.asked, value: _ago(r.createdAt)),
                          ],
                          decision: ApprovalActions.refund(ref, r),
                        ),
                    ],
                    if (a.expenses.isNotEmpty) ...[
                      SectionHeader('Expenses · ${a.expenses.length}'),
                      for (final e in a.expenses)
                        DecisionCard(
                          title: '${e.amount.label} · ${catalog.label('ExpenseCategory', e.category)}',
                          subtitle: e.payeeName ?? e.code,
                          facts: [
                            (label: ApprovalText.whatFor, value: e.description),
                            (label: ApprovalText.date, value: ClinicClock.date(e.expenseDate)),
                          ],
                          decision: ApprovalActions.expense(ref, e),
                        ),
                    ],
                    if (a.leaves.isNotEmpty) ...[
                      SectionHeader('Leave · ${a.leaves.length}'),
                      for (final l in a.leaves)
                        DecisionCard(
                          title: l.employee?.fullName ?? l.code,
                          subtitle: '${l.leaveType?.name ?? 'Leave'} · ${leaveDaysLabel(l)}',
                          facts: [
                            (label: ApprovalText.role, value: l.employee?.jobTitle),
                            (label: CommonText.reason, value: l.reason),
                            (
                              label: ApprovalText.documents,
                              value: (l.attachmentsCount ?? 0) > 0 ? '${l.attachmentsCount} attached' : null,
                            ),
                          ],
                          decision: ApprovalActions.leave(ref, l),
                        ),
                    ],
                    if (a.requests.isNotEmpty) ...[
                      SectionHeader('Late & overtime · ${a.requests.length}'),
                      for (final r in a.requests)
                        DecisionCard(
                          title: r.employee?.fullName ?? r.code,
                          subtitle:
                              '${catalog.label('StaffRequestType', r.type)} · ${formatMinutes(r.minutes)}'
                              '${r.attendance == null ? '' : ' on ${ClinicClock.date(r.attendance!.date)}'}',
                          facts: [
                            (label: ApprovalText.role, value: r.employee?.jobTitle),
                            (label: CommonText.reason, value: r.reason ?? CommonText.noReasonGiven),
                            (
                              label: r.isLate ? CommonText.ifNotExcused : CommonText.toPay,
                              value: r.details?.amount?.label,
                            ),
                            (label: ApprovalText.asked, value: _ago(r.createdAt)),
                          ],
                          decision: ApprovalActions.staffRequest(ref, r),
                        ),
                    ],
                    if (a.overtime.isNotEmpty) ...[
                      SectionHeader('Overtime · ${a.overtime.length}'),
                      for (final o in a.overtime)
                        DecisionCard(
                          title: o.employee?.fullName ?? ApprovalText.staffMember,
                          subtitle: '${formatMinutes(o.overtimeMinutes)} on ${ClinicClock.date(o.date)}',
                          facts: [
                            (label: ApprovalText.role, value: o.employee?.jobTitle),
                            (
                              label: CommonText.checkedOut,
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

String? _ago(DateTime? at) => at == null ? null : ClinicClock.ago(at);
