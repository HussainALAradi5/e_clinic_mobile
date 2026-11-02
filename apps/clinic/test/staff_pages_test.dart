import 'package:e_clinic_app/src/staff/application/calendar_providers.dart';
import 'package:e_clinic_app/src/staff/application/order_actions.dart';
import 'package:e_clinic_app/src/staff/staff_paths.dart';
import 'package:e_clinic_app/src/staff/utils/dispense_plan.dart';
import 'package:e_clinic_app/src/staff/utils/formatters.dart';
import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

Access _access(Set<String> permissions) => Access(permissions, signedIn: true);

Appointment _booking(String id, String provider, String name, String start, {AppointmentStatus? status}) => Appointment(
  id: id,
  code: id,
  patientId: 'p1',
  providerId: provider,
  provider: PersonRef(id: provider, fullName: name),
  type: AppointmentType.consultation,
  scheduledDate: '2026-10-29',
  startTime: start,
  endTime: start,
  status: status ?? AppointmentStatus.confirmed,
  version: 1,
);

PrescriptionItem _item(
  String id, {
  required String quantity,
  String? remaining,
  bool controlled = false,
  String? gtin,
}) => PrescriptionItem(
  id: id,
  medication: MedicationRef(id: 'm-$id', code: 'MED-$id', name: 'Med $id', isControlled: controlled, gtin: gtin),
  dose: '1 tab',
  frequency: 'twice a day',
  route: 'oral',
  durationDays: 5,
  quantity: quantity,
  remainingQuantity: remaining,
);

void main() {
  group('page rights', () {
    test('each staff path needs the right of its page, the most specific first', () {
      expect(StaffPaths.accessFor(StaffPaths.book), 'appointments.create');
      expect(StaffPaths.accessFor(StaffPaths.newLeave), 'leaves.create & leaves.request');
      expect(StaffPaths.accessFor(StaffPaths.leaves), StaffPage.leaves.access);
      expect(StaffPaths.accessFor(StaffPaths.dispenseFor('rx1')), StaffPage.dispense.access);
      expect(StaffPaths.accessFor(StaffPaths.dispensations), StaffPage.dispensations.access);
      expect(StaffPaths.accessFor(StaffPaths.appointment('a1')), 'appointments.read_all | appointments.read_own');
      // Tabs keep their own rights.
      expect(StaffPaths.accessFor(StaffPaths.sessions), StaffTab.sessions.access);
      expect(StaffPaths.accessFor(StaffPaths.today), Access.authenticated);
    });

    test('pharmacy is part of the staff area', () {
      expect(StaffPaths.owns(StaffPaths.dispense), isTrue);
      expect(StaffPaths.owns('/pharmacy-not'), isFalse);
    });

    test('More lists only the pages the role may open', () {
      final pharmacist = _access({'dispensing.create', 'dispensing.dispense', 'dispensing.read_all'});
      expect(StaffPage.visible(pharmacist), [StaffPage.inbox, StaffPage.dispense, StaffPage.dispensations]);

      final nurse = _access({
        'patients.read_own',
        'leaves.read_own',
        'attendance.self',
        'tickets.read_own',
        'chat.read_own',
      });
      expect(StaffPage.visible(nurse), [
        StaffPage.inbox,
        StaffPage.chat,
        StaffPage.tickets,
        StaffPage.patients,
        StaffPage.leaves,
        StaffPage.clock,
      ]);
    });

    test('opening a ticket needs tickets.create; a notification opens its record', () {
      expect(StaffPaths.accessFor(StaffPaths.newTicket), 'tickets.create');
      expect(StaffPaths.accessFor(StaffPaths.ticket('t1')), 'tickets.read_own | tickets.read_all');
      expect(StaffPaths.forNotification('support_ticket', 't1'), '/support/tickets/t1');
      expect(StaffPaths.forNotification('appointment', 'a1'), '/clinic/appointments/a1');
      expect(StaffPaths.forNotification('conversation', 'c1'), '/chat/c1');
      expect(StaffPaths.owns(StaffPaths.chat('c1')), isTrue);
      expect(StaffPaths.accessFor(StaffPaths.chat('c1')), 'chat.read_own | chat.read_all');
      expect(StaffPaths.forNotification(null, null), isNull);
    });

    test('a late excuse or overtime decision opens my requests, which need a staff request right', () {
      expect(StaffPaths.forNotification('staff_request', 'r1'), StaffPaths.requests);
      expect(StaffPaths.accessFor(StaffPaths.requests), 'staff_requests.read_own | staff_requests.read_all');
      expect(StaffTab.approvals.access, contains('staff_requests.review'));
    });
  });

  test('the calendar groups a day by provider, in time order, without cancelled bookings', () {
    final day = groupByProvider([
      _booking('a', 'd2', 'Zainab', '10:00'),
      _booking('b', 'd1', 'Ali', '11:00'),
      _booking('c', 'd2', 'Zainab', '09:00'),
      _booking('d', 'd1', 'Ali', '08:00', status: AppointmentStatus.cancelled),
    ]);
    expect(day.map((d) => d.name), ['Ali', 'Zainab']);
    expect(day.first.bookings.map((b) => b.id), ['b']);
    expect(day.last.bookings.map((b) => b.id), ['c', 'a']);
  });

  group('order steps', () {
    ClinicalOrder order(List<GenericStatus> next) => ClinicalOrder(
      id: 'o1',
      code: 'ORD-1',
      type: ClinicalOrderType.xray,
      description: 'Chest X-ray',
      status: GenericStatus.pending,
      allowedTransitions: next,
    );

    test('follow the status and the rights; start or result is the main button', () {
      final radiographer = _access({'orders.write', 'orders.perform'});
      final pending = order([GenericStatus.inProgress, GenericStatus.cancelled]);
      final actions = OrderAction.available(pending, radiographer);
      expect(actions, [OrderAction.start, OrderAction.cancel]);
      expect(OrderAction.primary(actions), OrderAction.start);

      final clerk = _access({'orders.write'});
      expect(OrderAction.available(pending, clerk), [OrderAction.cancel]);
      expect(OrderAction.primary(OrderAction.available(pending, clerk)), isNull);
    });
  });

  group('dispensing', () {
    final prescription = Prescription(
      id: 'rx1',
      code: 'RX-1',
      status: GenericStatus.inProgress,
      validUntil: '2026-12-31',
      items: [
        _item('i1', quantity: '10', remaining: '4', gtin: '6291100123456'),
        _item('i2', quantity: '2', remaining: '0'),
        _item('i3', quantity: '1', controlled: true),
      ],
    );

    test('starts with everything still owed', () {
      expect(owedQuantities(prescription), {'i1': 4.0, 'i3': 1.0});
    });

    test('sends only lines with a quantity; a controlled drug needs a witness', () {
      final quantities = {'i1': 2.5, 'i3': 0.0};
      expect(dispenseLines(prescription, quantities), [
        (medicationId: 'm-i1', prescriptionItemId: 'i1', quantity: '2.5'),
      ]);
      expect(needsWitness(prescription, quantities), isFalse);
      expect(needsWitness(prescription, {'i3': 1}), isTrue);
    });

    test('a scanned pack finds its line by barcode or medication code, and nothing else', () {
      expect(itemForBarcode(prescription, '6291100123456')?.id, 'i1');
      expect(itemForBarcode(prescription, '06291100123456')?.id, 'i1'); // GTIN-14 padding
      expect(itemForBarcode(prescription, 'med-i3')?.id, 'i3');
      expect(itemForBarcode(prescription, '5000000000000'), isNull);
      expect(itemForBarcode(prescription, '  '), isNull);
    });
  });

  group('order files', () {
    ClinicalOrder order(ClinicalOrderType type, GenericStatus status) =>
        ClinicalOrder(id: 'o1', code: 'ORD-1', type: type, description: 'x', status: status);

    test('photos go on open or done orders for those who may attach to orders', () {
      final doctor = _access({'attachments.create', 'orders.write'});
      expect(canAttach(order(ClinicalOrderType.xray, GenericStatus.inProgress), doctor), isTrue);
      expect(canAttach(order(ClinicalOrderType.xray, GenericStatus.cancelled), doctor), isFalse);
      expect(
        canAttach(order(ClinicalOrderType.xray, GenericStatus.completed), _access({'attachments.create'})),
        isFalse,
      );
    });

    test('each kind of order files its photo under the right category', () {
      expect(resultCategory(ClinicalOrderType.mri), AttachmentCategory.xrayImage);
      expect(resultCategory(ClinicalOrderType.labTest), AttachmentCategory.labResult);
      expect(resultCategory(ClinicalOrderType.ecg), AttachmentCategory.labResult);
      expect(resultCategory(ClinicalOrderType.referral), AttachmentCategory.referralLetter);
    });
  });

  test('units agree with the quantity', () {
    expect(unitLabel('tablet', 1), 'tablet');
    expect(unitLabel('tablet', 20), 'tablets');
    expect(unitLabel('ml', 5), 'ml');
    expect(unitLabel(null, 2), '');
  });

  test('quantities read the way people write them', () {
    expect(formatQuantity(2), '2');
    expect(formatQuantity(2.5), '2.5');
    expect(formatQuantity(0.25), '0.25');
    expect(formatQuantity(1.10), '1.1');
  });
}
