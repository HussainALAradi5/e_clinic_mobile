part of 'ticket_detail_screen.dart';

/// Screenshots and files on the ticket, and "Add a photo" while it is open to [canAdd] people.
class _TicketFiles extends StatelessWidget {
  const _TicketFiles({required this.ticket, required this.canAdd, required this.onUploaded});

  final SupportTicket ticket;
  final bool canAdd;
  final VoidCallback onUploaded;

  @override
  Widget build(BuildContext context) {
    if (ticket.attachments.isEmpty && !canAdd) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Screenshots & files'),
        if (ticket.attachments.isNotEmpty) AttachmentList(files: ticket.attachments),
        if (canAdd)
          Align(
            alignment: Alignment.centerLeft,
            child: AttachPhotoButton(
              ownerType: 'support_ticket',
              ownerId: ticket.id,
              category: AttachmentCategory.ticketAttachment,
              label: 'Add a photo',
              onUploaded: (_) => onUploaded(),
            ),
          ),
      ],
    );
  }
}
