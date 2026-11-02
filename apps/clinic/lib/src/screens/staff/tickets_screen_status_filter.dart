part of 'tickets_screen.dart';

/// Status chips of the ticket list (GenericStatus on the server).
enum _StatusFilter {
  all('All', []),
  open('Open', [GenericStatus.pending, GenericStatus.inProgress]),
  pending('Pending', [GenericStatus.pending]),
  inProgress('In progress', [GenericStatus.inProgress]),
  completed('Solved', [GenericStatus.completed]),
  cancelled('Cancelled', [GenericStatus.cancelled]);

  const _StatusFilter(this.label, this.statuses);
  final String label;
  final List<GenericStatus> statuses;
}
