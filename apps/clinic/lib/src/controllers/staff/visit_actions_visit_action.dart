part of 'visit_actions.dart';

/// Steps of a visit. One shows when the booking may move to its target status **and** the user holds the right
/// (same expressions as the server routes, which check again).
enum VisitAction {
  checkIn(
    VisitActionText.checkIn,
    Icons.how_to_reg_rounded,
    AppointmentStatus.checkedIn,
    'appointments.write & appointments.check_in',
  ),
  start(VisitActionText.start, Icons.play_arrow_rounded, AppointmentStatus.inProgress, 'appointments.write & appointments.treat'),
  complete(VisitActionText.complete, Icons.task_alt_rounded, AppointmentStatus.completed, 'appointments.write & appointments.treat'),
  confirm(VisitActionText.confirm, Icons.event_available_rounded, AppointmentStatus.confirmed, 'appointments.write'),
  noShow(VisitActionText.noShow, Icons.person_off_outlined, AppointmentStatus.noShow, 'appointments.write');

  const VisitAction(this.label, this.icon, this.target, this.access);

  final String label;
  final IconData icon;
  final AppointmentStatus target;
  final String access;

  /// What this user can do with the booking now, the main step first.
  static List<VisitAction> available(Appointment visit, Access access) => [
    for (final action in values)
      if (visit.canMoveTo(action.target) &&
          access.can(action.access) &&
          (action != checkIn || visit.checkInOpen(DateTime.now())))
        action,
  ];

  /// The big button of a card: the next step of the visit (never no-show, which stays in the menu).
  static VisitAction? primary(List<VisitAction> actions) => actions.where((a) => a != noShow).firstOrNull;
}
