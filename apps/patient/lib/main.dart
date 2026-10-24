import 'package:e_clinic_core/core.dart';
import 'package:e_clinic_features/features.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';

/// API origin: `flutter run --dart-define=API_URL=https://api.clinic.bh/api/v1`.
/// The default reaches `php artisan serve` on the host from the Android emulator.
const _apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api/v1');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Failed loads show a retry button instead of retrying silently.
      retry: (retryCount, error) => null,
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(app: MobileApp.patient, apiBaseUrl: _apiUrl, lockAfter: Duration(minutes: 5)),
        ),
        preferencesProvider.overrideWithValue(preferences),
        sessionExpiredProvider.overrideWith((ref) => () => ref.read(sessionProvider.notifier).expire()),
      ],
      child: const PatientApp(),
    ),
  );
}
