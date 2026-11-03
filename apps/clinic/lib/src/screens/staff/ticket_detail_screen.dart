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

part 'ticket_detail_screen_ask_card.dart';
part 'ticket_detail_screen_comment_bubble.dart';
part 'ticket_detail_screen_reply_box.dart';
part 'ticket_detail_screen_solved_banner.dart';
part 'ticket_detail_screen_step_bar.dart';
part 'ticket_detail_screen_ticket_facts.dart';
part 'ticket_detail_screen_ticket_files.dart';
part 'ticket_detail_screen_ticket_header.dart';

/// `/support/tickets/:id` — the ticket with its status, priority and category badges, who opened and took it,
/// the replies, a reply box, and for admins the next steps (take it, mark solved, back to queue / reopen, cancel).
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
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

  Future<void> _send(String body) async {
    await ref.read(ticketRepositoryProvider).comment(widget.id, body);
    ref.invalidate(ticketProvider(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(ticketProvider(widget.id));
    final desk = ref.watch(accessProvider).can('tickets.resolve');
    final me = ref.watch(sessionProvider).value?.user.id;
    final ticket = value.value;
    final steps = ticket == null || !desk ? const <_Step>[] : _StepBar.stepsFor(ticket);
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
              _TicketHeader(ticket: t),
              if (t.status == GenericStatus.completed && t.resolution != null) ...[
                const SizedBox(height: 12),
                _SolvedBanner(ticket: t),
              ],
              if (t.awaitsConfirmation && t.requester?.id == me) ...[
                const SizedBox(height: 12),
                _AskCard(onConfirm: _confirm, onDecline: _decline),
              ],
              const SizedBox(height: 16),
              _TicketFacts(ticket: t),
              _TicketFiles(
                ticket: t,
                canAdd: t.status != GenericStatus.cancelled && (desk || t.requester?.id == me),
                onUploaded: () => ref.invalidate(ticketProvider(widget.id)),
              ),
              SectionHeader('Conversation (${t.comments.length})'),
              if (t.comments.isEmpty)
                Text('No replies yet.', style: theme.textTheme.bodyMedium)
              else
                for (final c in t.comments) _CommentBubble(comment: c),
              const SizedBox(height: 12),
              if (t.status == GenericStatus.cancelled)
                const InfoNote(icon: Icons.lock_outline_rounded, text: 'This ticket is cancelled — no more replies.')
              else
                _ReplyBox(onSend: _send),
            ],
          ),
        ),
      ),
      bottomNavigationBar: steps.isEmpty || ticket == null
          ? null
          : _StepBar(steps: steps, onStep: (step) => _move(ticket, step)),
    );
  }
}
