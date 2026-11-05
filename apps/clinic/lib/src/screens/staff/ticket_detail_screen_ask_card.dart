part of 'ticket_detail_screen.dart';

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
                TicketText.didThisFixIt,
                style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(TicketText.askHint, style: TextStyle(color: fg)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: TicketText.notFixed,
                  icon: Icons.thumb_down_alt_outlined,
                  variant: ButtonVariant.outlined,
                  onPressed: onDecline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(label: TicketText.itWorks, icon: Icons.thumb_up_alt_rounded, onPressed: onConfirm),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
