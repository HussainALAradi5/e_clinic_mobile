import 'package:e_clinic_core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shows wall-clock times on the 12-hour clock with AM / PM', () {
    expect(ClinicClock.wallTime('09:05'), '9:05 AM');
    expect(ClinicClock.wallTime('16:00:00'), '4:00 PM');
    expect(ClinicClock.wallTime('00:30'), '12:30 AM');
    expect(ClinicClock.wallTime('12:00'), '12:00 PM');
    expect(ClinicClock.wallTime('soon'), 'soon');
    expect(ClinicClock.timeRange('09:00', '09:15'), '9:00 AM – 9:15 AM');
  });

  test('shows instants in clinic time (UTC+3) with AM / PM', () {
    expect(ClinicClock.dateTime(DateTime.utc(2026, 11, 4, 15, 54)), '4 Nov 2026, 6:54 PM');
  });
}
