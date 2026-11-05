part of 'tickets_screen.dart';

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.showRequester});

  final SupportTicket ticket;
  final bool showRequester;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(StaffPaths.ticket(ticket.id)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(ticket.code, style: muted?.copyWith(fontFamily: 'monospace')),
                  const Spacer(),
                  Text(ClinicClock.ago(ticket.createdAt), style: muted),
                ],
              ),
              const SizedBox(height: 4),
              Text(ticket.subject, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  StatusChip(enumName: 'GenericStatus', value: ticket.status),
                  StatusChip(enumName: 'TreatmentPriority', value: ticket.priority),
                  StatusChip(enumName: 'TicketCategory', value: ticket.category),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        if (showRequester && ticket.requester != null) TicketText.byName(ticket.requester!.fullName),
                        ticket.assignee == null ? TicketText.notTakenYet : TicketText.takenByName(ticket.assignee!.fullName),
                      ].join(' · '),
                      style: muted,
                    ),
                  ),
                  if ((ticket.commentsCount ?? 0) > 0) ...[
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('${ticket.commentsCount}', style: muted),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
