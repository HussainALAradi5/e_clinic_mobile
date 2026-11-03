part of 'ticket_detail_screen.dart';

/// One admin step of the ticket flow (the moves the server allows from the current status).
typedef _Step = ({GenericStatus to, String label, IconData icon, ButtonVariant variant});

/// The admin's next steps along the bottom (only the moves the server allows from the current status).
class _StepBar extends StatelessWidget {
  const _StepBar({required this.steps, required this.onStep});

  /// The steps open to an admin from the ticket's current status.
  static List<_Step> stepsFor(SupportTicket t) => [
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

  final List<_Step> steps;
  final Future<void> Function(_Step step) onStep;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            for (final step in steps)
              AppButton(label: step.label, icon: step.icon, variant: step.variant, onPressed: () => onStep(step)),
          ],
        ),
      ),
    );
  }
}
