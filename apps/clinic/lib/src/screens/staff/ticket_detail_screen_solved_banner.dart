part of 'ticket_detail_screen.dart';

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
                  TicketText.solvedBanner(ticket.resolver?.fullName),
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(ticket.resolution ?? '', style: TextStyle(color: fg)),
                if (ticket.resolutionSteps.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    TicketText.stepsTaken,
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
