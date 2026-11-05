part of 'ticket_detail_screen.dart';

/// Who opened, took and solved the ticket and when, then what happened.
class _TicketFacts extends StatelessWidget {
  const _TicketFacts({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: FactList(
            facts: [
              (label: TicketText.openedBy, value: t.requester?.fullName),
              (label: TicketText.opened, value: ClinicClock.dateTime(t.createdAt)),
              (label: TicketText.takenBy, value: t.assignee?.fullName ?? TicketText.notTakenYet),
              (label: TicketText.solvedBy, value: t.resolver?.fullName),
              (label: TicketText.solved, value: t.resolvedAt == null ? null : ClinicClock.dateTime(t.resolvedAt!)),
            ],
          ),
        ),
        const SectionHeader(TicketText.whatHappenedHeader),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(t.description, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
