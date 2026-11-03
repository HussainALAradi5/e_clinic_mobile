import 'package:e_clinic_data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a message kind comes from its template area; urgent ones win', () {
    expect(notificationKindOf('appointment.reminder'), NotificationKind.visit);
    expect(notificationKindOf('order.result_ready'), NotificationKind.result);
    expect(notificationKindOf('order.abnormal'), NotificationKind.urgent);
    expect(notificationKindOf('treatment.urgent'), NotificationKind.urgent);
    expect(notificationKindOf('prescription.created'), NotificationKind.pharmacy);
    expect(notificationKindOf('refund.approved'), NotificationKind.billing);
    expect(notificationKindOf('leave.approved'), NotificationKind.hr);
    expect(notificationKindOf('chat.mention'), NotificationKind.chat);
    expect(notificationKindOf('ticket.resolved'), NotificationKind.support);
    expect(notificationKindOf('task.completed'), NotificationKind.system);
  });

  test('every kind has its own sound', () {
    final sounds = NotificationKind.values.map((k) => k.sound).toSet();
    expect(sounds, hasLength(NotificationKind.values.length));
  });
}
