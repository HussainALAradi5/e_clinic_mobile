import 'package:e_clinic_core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

enum _Status { checkedIn, noShow }

void main() {
  test('requests go to <api>/<path> whether or not the configured URL ends in a slash', () {
    for (final url in ['http://10.0.2.2:8000/api/v1', 'http://10.0.2.2:8000/api/v1/']) {
      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(AppConfig(app: MobileApp.staff, apiBaseUrl: url, lockAfter: Duration.zero)),
        ],
      );
      addTearDown(container.dispose);
      final dio = container.read(dioProvider);
      expect(Uri.parse(dio.options.baseUrl).resolve('auth/login').toString(), 'http://10.0.2.2:8000/api/v1/auth/login');
      expect(container.read(apiClientProvider).baseUrl, 'http://10.0.2.2:8000/api/v1');
    }
  });

  group('Access', () {
    const access = Access({'invoices.read_all', 'invoices.issue'}, signedIn: true);

    test('evaluates and / or / not with parentheses', () {
      expect(access.can('invoices.read_all & invoices.issue'), isTrue);
      expect(access.can('invoices.write | invoices.issue'), isTrue);
      expect(access.can('!(invoices.write) & authenticated'), isTrue);
      expect(access.can('invoices.write'), isFalse);
    });

    test('read_all implies read_own; guests can do nothing', () {
      expect(access.can('invoices.read_own'), isTrue);
      expect(Access.guest.can('authenticated'), isFalse);
    });
  });

  group('ListQuery', () {
    test('flattens the filter tree in snake_case', () {
      final params = const ListQuery(
        page: 2,
        perPage: 20,
        sort: ['-scheduledDate', 'startTime'],
        filter: AllOf([
          Where.oneOf('status', [_Status.checkedIn, _Status.noShow]),
          Where.gte('scheduledDate', '2026-11-01'),
        ]),
      ).toParams();
      expect(params, {
        'page': '2',
        'per_page': '20',
        'sort': '-scheduled_date,start_time',
        'filter[and][0][status][in]': 'checked_in,no_show',
        'filter[and][1][scheduled_date][gte]': '2026-11-01',
      });
    });
  });

  group('MoneyFormat', () {
    test('formats and sums exactly in fils', () {
      expect(MoneyFormat.toMinor('25.5'), 25500);
      expect(MoneyFormat.fromMinor(-1250500), '-1250.500');
      expect(MoneyFormat.format('1250.5'), 'BHD 1,250.500');
    });
  });

  group('ClinicClock', () {
    test('adds days across months and names the day', () {
      expect(ClinicClock.addDays('2026-10-30', 3), '2026-11-02');
      expect(ClinicClock.day('2026-10-25'), 'Sun 25 Oct 2026');
    });
  });
}
