import 'package:e_clinic_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/auth/session_controller.dart';
import 'services/auth/access_notice.dart';

/// API origin: `flutter run --dart-define=API_URL=https://api.clinic.bh`.
/// The default reaches `php artisan serve` on the host from the Android emulator.
const _apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

/// Starts the e-Clinic app: loads the settings, wires the API and the session, then shows [root].
Future<void> runClinicApp({required Widget root}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Failed loads show a retry button instead of retrying silently.
      retry: (retryCount, error) => null,
      overrides: [
        appConfigProvider.overrideWithValue(const AppConfig(apiBaseUrl: _apiUrl)),
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
