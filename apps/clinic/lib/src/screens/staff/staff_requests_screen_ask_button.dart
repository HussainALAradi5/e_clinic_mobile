part of 'staff_requests_screen.dart';

class _AskButton extends StatelessWidget {
  const _AskButton({required this.late, required this.minutes, required this.onTap});

  final bool late;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = RequestTone.of(context, late: late);
    final style = Theme.of(context).textTheme.bodyLarge?.copyWith(color: tone);
    return Material(
      color: RequestTone.soft(context, late: late),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(RequestTone.icon(late: late), color: tone),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: late ? 'Late ' : 'Overtime ',
                    children: [
                      TextSpan(
                        text: formatMinutes(minutes),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: late ? ' · ask to excuse' : ' · ask to pay'),
                    ],
                  ),
                  style: style,
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: tone),
            ],
          ),
        ),
      ),
    );
  }
}
