import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../api/interceptors.dart';
import '../auth/token_store.dart';
import 'app_config.dart';

/// Overridden in each app's `main.dart`.
final appConfigProvider = Provider<AppConfig>(
  (ref) => throw UnimplementedError('Override appConfigProvider in main().'),
);

/// Loaded before `runApp` and overridden there, so settings can be read synchronously.
final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override preferencesProvider in main().'),
);

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// Called by the auth interceptor when the server rejects the stored token (expired or revoked elsewhere).
/// The session feature overrides it to sign the user out.
final sessionExpiredProvider = Provider<void Function()>((ref) => () {});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final dio = Dio(
    BaseOptions(
      // Dio joins the base and a relative path as text: without the slash `.../api/v1` + `auth/login`
      // would become `.../api/v1auth/login`.
      baseUrl: config.apiBaseUrl.endsWith('/') ? config.apiBaseUrl : '${config.apiBaseUrl}/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.addAll([
    RequestIdInterceptor(),
    AuthInterceptor(tokens: ref.watch(tokenStoreProvider), onExpired: () => ref.read(sessionExpiredProvider)()),
    RetryInterceptor(dio),
  ]);
  return dio;
});

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(dioProvider)));
