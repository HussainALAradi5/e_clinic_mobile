import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth/session_controller.dart';
import 'services/auth/access_notice.dart';

/// API origin: `flutter run --dart-define=API_URL=https://api.clinic.bh`.
/// The default reaches `php artisan serve` on the host from the Android emulator.
const _apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

/// Live updates (Reverb): `--dart-define=REVERB_KEY=… --dart-define=REVERB_HOST=… --dart-define=REVERB_PORT=8085
/// --dart-define=REVERB_SCHEME=http`. Without a key and host the app polls.
final _reverb = ReverbConfig.fromValues(
  key: const String.fromEnvironment('REVERB_KEY'),
  host: const String.fromEnvironment('REVERB_HOST'),
  port: const String.fromEnvironment('REVERB_PORT'),
  scheme: const String.fromEnvironment('REVERB_SCHEME'),
);

/// Starts the e-Clinic app: loads the settings, wires the API and the session, then shows [root].
Future<void> runClinicApp({required Widget root}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Failed loads show a retry button instead of retrying silently.
      retry: (retryCount, error) => null,
      overrides: [
        appConfigProvider.overrideWithValue(AppConfig(apiBaseUrl: _apiUrl, reverb: _reverb)),
        preferencesProvider.overrideWithValue(preferences),
        sessionExpiredProvider.overrideWith(
          (ref) => () {
            if (ref.read(sessionProvider).value != null) AccessNotice.sessionEnded();
            ref.read(sessionProvider.notifier).expire();
          },
        ),
      ],
      child: root,
    ),
  );
}
