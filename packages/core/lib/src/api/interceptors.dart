import 'dart:async';

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../auth/token_store.dart';

const _uuid = Uuid();

/// `X-Request-Id` on every call, so an error message can be matched to the server log.
class RequestIdInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.putIfAbsent('X-Request-Id', () => _uuid.v4());
    handler.next(options);
  }
}

/// Adds the bearer token; a 401 on a call that carried one means the session ended elsewhere.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokens, required this.onExpired});

  final TokenStore tokens;
  final void Function() onExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokens.current;
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final sentToken = err.requestOptions.headers.containsKey('Authorization');
    if (err.response?.statusCode == 401 && sentToken) onExpired();
    handler.next(err);
  }
}

/// Retries reads (and keyed writes, which the server de-duplicates) after network failures: 3 tries, 0.5 s → 2 s.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(this._dio);

  final Dio _dio;
  static const _maxRetries = 3;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry'] as int?) ?? 0;
    final safe = options.method == 'GET' || options.headers.containsKey('Idempotency-Key');
    final network = err.response == null &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout);
    if (!safe || !network || attempt >= _maxRetries) {
      handler.next(err);
      return;
    }
    await Future<void>.delayed(Duration(milliseconds: 500 * (1 << attempt)));
    options.extra['retry'] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
