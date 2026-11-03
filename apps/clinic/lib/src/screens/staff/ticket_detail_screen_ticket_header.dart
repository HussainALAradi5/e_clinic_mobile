part of 'ticket_detail_screen.dart';

/// The subject with the status, priority, category and confirmation badges.
class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.subject, style: Theme.of(context).textTheme.headlineSmall),
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
      ],
    );
  }
}
