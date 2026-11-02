import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:e_clinic_shell/shell.dart';
import 'package:e_clinic_ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/staff/support_providers.dart';
import '../../widgets/common/attach_photo_button.dart';
import '../../widgets/common/attachment_list.dart';
import '../../widgets/staff/support/solve_steps_sheet.dart';

/// One admin step of the ticket flow (the moves the server allows from the current status).
typedef _Step = ({GenericStatus to, String label, IconData icon, ButtonVariant variant});

/// `/support/tickets/:id` — the ticket with its status, priority and category badges, who opened and took it,
/// the replies, a reply box, and for admins the next steps (take it, mark solved, back to queue / reopen, cancel).
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _reply = TextEditingController();

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  List<_Step> _steps(SupportTicket t) => [
    (to: GenericStatus.inProgress, label: 'Take it', icon: Icons.assignment_ind_rounded, variant: ButtonVariant.tonal),
    (to: GenericStatus.completed, label: 'Mark solved', icon: Icons.task_alt_rounded, variant: ButtonVariant.filled),
    (
      to: GenericStatus.pending,
      label: t.status == GenericStatus.completed ? 'Reopen' : 'Back to queue',
      icon: Icons.undo_rounded,
      variant: ButtonVariant.outlined,
    ),
    (to: GenericStatus.cancelled, label: 'Cancel', icon: Icons.block_rounded, variant: ButtonVariant.outlined),
  ].where((s) => t.allowedTransitions.contains(s.to)).toList();

  Future<void> _move(SupportTicket t, _Step step) async {
    TicketSolution? solution;
    if (step.to == GenericStatus.completed) {
      solution = await showSolveStepsSheet(context, requester: t.requester?.fullName ?? 'The requester');
      if (solution == null) return;
    } else if (step.to == GenericStatus.cancelled) {
      final ok = await showConfirmSheet(
        context,
        const ConfirmConfig(
          title: 'Cancel this ticket?',
          message: 'A cancelled ticket is final: no more replies or status changes.',
          confirmLabel: 'Cancel ticket',
          danger: true,
        ),
      );
      if (!ok) return;
    }
    await ref
        .read(ticketRepositoryProvider)
        .setStatus(t, step.to, resolution: solution?.resolution, steps: solution?.steps);
    ref.invalidate(ticketProvider(widget.id));
    if (mounted) AppSnack.success(context, '${t.code}: ${step.label.toLowerCase()} — done.');
  }

  Future<void> _confirm() async {
    await ref.read(ticketRepositoryProvider).confirm(widget.id);
    ref.invalidate(ticketProvider(widget.id));
    if (mounted) AppSnack.success(context, 'Thanks — the support team is told it works.');
  }

  Future<void> _decline() async {
    final reason = await showReasonSheet(
      context,
      const ConfirmConfig(
        title: 'Still not fixed?',
        message: 'Say what still happens; the ticket goes back to the support team.',
        confirmLabel: 'Not fixed',
        danger: true,
      ),
      label: 'What still happens',
    );
    if (reason == null) return;
    await ref.read(ticketRepositoryProvider).decline(widget.id, reason);
    ref.invalidate(ticketProvider(widget.id));
    if (mounted) AppSnack.success(context, 'Sent back to the support team.');
  }

  Future<void> _send() async {
    final body = _reply.text.trim();
    if (body.isEmpty) return;
    await ref.read(ticketRepositoryProvider).comment(widget.id, body);
    _reply.clear();
    ref.invalidate(ticketProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(ticketProvider(widget.id));
    final desk = ref.watch(accessProvider).can('tickets.resolve');
    final me = ref.watch(sessionProvider).value?.user.id;
    final ticket = value.value;
    final steps = ticket == null || !desk ? const <_Step>[] : _steps(ticket);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(ticket?.code ?? 'Ticket')),
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(ticketProvider(widget.id)),
        data: (t) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(ticketProvider(widget.id)),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Text(t.subject, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  StatusChip(enumName: 'GenericStatus', value: t.status),
                  StatusChip(enumName: 'TreatmentPriority', value: t.priority),
                  StatusChip(enumName: 'TicketCategory', value: t.category),
                  if (t.confirmation != null) StatusChip(enumName: 'TicketConfirmation', value: t.confirmation!),
                ],
              ),
              if (t.status == GenericStatus.completed && t.resolution != null) ...[
                const SizedBox(height: 12),
                _SolvedBanner(ticket: t),
              ],
              if (t.awaitsConfirmation && t.requester?.id == me) ...[
                const SizedBox(height: 12),
                _AskCard(onConfirm: _confirm, onDecline: _decline),
              ],
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: FactList(
                  facts: [
                    (label: 'Opened by', value: t.requester?.fullName),
                    (label: 'Opened', value: ClinicClock.dateTime(t.createdAt)),
                    (label: 'Taken by', value: t.assignee?.fullName ?? 'Not taken yet'),
                    (label: 'Solved by', value: t.resolver?.fullName),
                    (label: 'Solved', value: t.resolvedAt == null ? null : ClinicClock.dateTime(t.resolvedAt!)),
                  ],
                ),
              ),
              const SectionHeader('What happened'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(t.description, style: theme.textTheme.bodyMedium),
                ),
              ),
              if (t.attachments.isNotEmpty || (t.status != GenericStatus.cancelled && (desk || t.requester?.id == me)))
                const SectionHeader('Screenshots & files'),
              if (t.attachments.isNotEmpty) AttachmentList(files: t.attachments),
              if (t.status != GenericStatus.cancelled && (desk || t.requester?.id == me))
                Align(
                  alignment: Alignment.centerLeft,
                  child: AttachPhotoButton(
                    ownerType: 'support_ticket',
                    ownerId: t.id,
                    category: AttachmentCategory.ticketAttachment,
                    label: 'Add a photo',
                    onUploaded: (_) => ref.invalidate(ticketProvider(widget.id)),
                  ),
                ),
              SectionHeader('Conversation (${t.comments.length})'),
              if (t.comments.isEmpty)
                Text('No replies yet.', style: theme.textTheme.bodyMedium)
              else
                for (final c in t.comments) _CommentBubble(comment: c),
              const SizedBox(height: 12),
              if (t.status == GenericStatus.cancelled)
                const InfoNote(icon: Icons.lock_outline_rounded, text: 'This ticket is cancelled — no more replies.')
              else ...[
                TextField(
                  controller: _reply,
                  minLines: 2,
                  maxLines: 5,
                  maxLength: 5000,
                  decoration: const InputDecoration(labelText: 'Write a reply', border: OutlineInputBorder()),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(label: 'Send', icon: Icons.send_rounded, onPressed: _send),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: steps.isEmpty || ticket == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    for (final step in steps)
                      AppButton(
                        label: step.label,
                        icon: step.icon,
                        variant: step.variant,
                        onPressed: () => _move(ticket, step),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _SolvedBanner extends StatelessWidget {
  const _SolvedBanner({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFDCFCE7) : const Color(0xFF14532D);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.task_alt_rounded, color: dark ? const Color(0xFF86EFAC) : const Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solved${ticket.resolver == null ? '' : ' by ${ticket.resolver!.fullName}'}',
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(ticket.resolution ?? '', style: TextStyle(color: fg)),
                if (ticket.resolutionSteps.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Steps taken',
                    style: TextStyle(color: fg, fontWeight: FontWeight.w600),
                  ),
                ],
                for (final (i, step) in ticket.resolutionSteps.indexed)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('${i + 1}. $step', style: TextStyle(color: fg)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({required this.comment});

  final TicketComment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = comment.isMe;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mine
              ? Color.alphaBlend(const Color(0xFF2563EB).withValues(alpha: 0.14), scheme.surfaceContainerLowest)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(mine ? 'You' : comment.author.fullName, style: theme.textTheme.labelMedium),
                if (comment.author.isSupport) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(99)),
                    child: Text(
                      'SUPPORT',
                      style: theme.textTheme.labelSmall?.copyWith(color: scheme.onPrimaryContainer, fontSize: 9),
                    ),
                  ),
                ],
                const SizedBox(width: 6),
                Text(ClinicClock.ago(comment.createdAt), style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment.body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// "Did this fix it?" — the requester's answer to a solved ticket.
class _AskCard extends StatelessWidget {
  const _AskCard({required this.onConfirm, required this.onDecline});

  final Future<void> Function() onConfirm;
  final Future<void> Function() onDecline;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fg = dark ? const Color(0xFFFDE68A) : const Color(0xFF78350F);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF422006) : const Color(0xFFFFFBEB),
        border: Border.all(color: const Color(0xFFF59E0B)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_rounded, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Text(
                'Did this fix it?',
                style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Try it, then tell the support team. If it still happens, say what you see.',
            style: TextStyle(color: fg),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Not fixed',
                  icon: Icons.thumb_down_alt_outlined,
                  variant: ButtonVariant.outlined,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(label: 'It works', icon: Icons.thumb_up_alt_rounded, onPressed: onConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
