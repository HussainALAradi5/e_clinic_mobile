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
            child: SelectableText(t.description, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
