import 'package:e_clinic_app/src/staff/application/approval_actions.dart';
import 'package:e_clinic_app/src/staff/application/visit_actions.dart';
import 'package:e_clinic_app/src/staff/staff_paths.dart';
import 'package:e_clinic_app/src/staff/widgets/appointment_card.dart';
import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

Access _access(Set<String> permissions) => Access(permissions, signedIn: true);

Appointment _visit(List<AppointmentStatus> next) => Appointment(
  id: 'a1',
  code: 'APT-1',
  patientId: 'p1',
  providerId: 'd1',
  type: AppointmentType.consultation,
  scheduledDate: '2026-10-25',
  startTime: '09:00',
  endTime: '09:15',
  status: AppointmentStatus.confirmed,
  allowedTransitions: next,
  version: 1,
);

void main() {
  group('tabs', () {
    test('show only what the role may open, Today and More always', () {
      final reception = _access({'codes.read_all', 'codes.scan', 'appointments.read_all'});
      expect(StaffTab.visible(reception), [StaffTab.today, StaffTab.scan, StaffTab.more]);

      final accountant = _access({'refunds.approve', 'expenses.approve'});
      expect(StaffTab.visible(accountant), [StaffTab.today, StaffTab.approvals, StaffTab.more]);
    });

    test('a location belongs to its tab, anything else to Today', () {
      expect(StaffTab.of('/scan'), StaffTab.scan);
      expect(StaffTab.of('/clinic/sessions'), StaffTab.sessions);
      expect(StaffTab.of('/clinic/appointments/a1'), StaffTab.today);
      expect(StaffTab.of('/'), StaffTab.today);
    });
  });

  group('visit actions', () {
    final frontDesk = _access({'appointments.write', 'appointments.check_in'});
    final therapist = _access({'appointments.write', 'appointments.treat'});

    test('need both the next status and the right', () {
      final arriving = _visit([AppointmentStatus.checkedIn, AppointmentStatus.noShow, AppointmentStatus.cancelled]);
      expect(VisitAction.available(arriving, frontDesk), [VisitAction.checkIn, VisitAction.noShow]);
      expect(VisitAction.available(arriving, therapist), [VisitAction.noShow]);

      final waiting = _visit([AppointmentStatus.inProgress]);
      expect(VisitAction.available(waiting, frontDesk), isEmpty);
      expect(VisitAction.available(waiting, therapist), [VisitAction.start]);
    });

    test('no-show is never the main button', () {
      expect(VisitAction.primary([VisitAction.noShow]), isNull);
      expect(VisitAction.primary([VisitAction.checkIn, VisitAction.noShow]), VisitAction.checkIn);
    });
  });

  test('a booking is late 10 minutes after its start; a checked-in patient shows the wait', () {
    final today = ClinicClock.today();
    DateTime at(int h, int m) => DateTime.utc(2026, 1, 1, h, m);
    final booked = _visit([]).copyWith(scheduledDate: today);

    expect(visitTiming(booked, now: at(9, 10)), isNull);
    expect(visitTiming(booked, now: at(9, 25))?.text, 'Late 25 min');
    expect(visitTiming(booked.copyWith(scheduledDate: '2020-01-01'), now: at(12, 0)), isNull);

    // 08:50 UTC = 11:50 in the clinic.
    final waiting = booked.copyWith(status: AppointmentStatus.checkedIn, checkedInAt: DateTime.utc(2026, 1, 1, 8, 50));
    expect(visitTiming(waiting, now: at(12, 2))?.text, 'Waiting 12 min');
  });

  test('minutes read as hours and minutes', () {
    expect(ApprovalActions.minutesLabel(40), '40 min');
    expect(ApprovalActions.minutesLabel(60), '1 h');
    expect(ApprovalActions.minutesLabel(85), '1 h 25 min');
  });
}
