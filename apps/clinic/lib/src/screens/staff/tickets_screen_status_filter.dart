part of 'tickets_screen.dart';

/// Status chips of the ticket list (GenericStatus on the server).
enum _StatusFilter {
  all(CommonText.all, []),
  open(TicketText.open, [GenericStatus.pending, GenericStatus.inProgress]),
  pending(TicketText.pending, [GenericStatus.pending]),
  inProgress(TicketText.inProgress, [GenericStatus.inProgress]),
  completed(TicketText.solved, [GenericStatus.completed]),
  cancelled(TicketText.cancelled, [GenericStatus.cancelled]);

  const _StatusFilter(this.label, this.statuses);
  final String label;
  final List<GenericStatus> statuses;
}
